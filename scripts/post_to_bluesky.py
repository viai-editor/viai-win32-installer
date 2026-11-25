#!/usr/bin/env python3
"""Post a text to Bluesky, with its URLs and hashtags as links and a link
card for the first URL.

Usage: post_to_bluesky.py TEXT

The account is taken from the environment variables BLUESKY_HANDLE and
BLUESKY_APP_PASSWORD (an app password, not the account password).
"""

import datetime
import html.parser
import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request

PDS = 'https://bsky.social/xrpc/'
URL_RE = re.compile(r'https?://\S+')
# The largest image Bluesky takes for a link card.
MAX_THUMB = 1000000


def call(method, body, token=None, content_type='application/json'):
    headers = {'Content-Type': content_type}
    if token:
        headers['Authorization'] = f'Bearer {token}'
    if content_type == 'application/json':
        body = json.dumps(body).encode()
    req = urllib.request.Request(PDS + method, data=body, headers=headers,
                                 method='POST')
    with urllib.request.urlopen(req, timeout=30) as res:
        return json.load(res)


def fetch(url):
    req = urllib.request.Request(url,
                                 headers={'User-Agent': 'post_to_bluesky'})
    with urllib.request.urlopen(req, timeout=30) as res:
        return res.read(MAX_THUMB + 1), res.headers.get_content_type()


def facets(text):
    # Bluesky makes nothing a link by itself.  A facet gives the range in
    # UTF-8 bytes.
    result = []

    def add(m, feature):
        start = len(text[:m.start()].encode())
        end = len(text[:m.end()].encode())
        result.append({'index': {'byteStart': start, 'byteEnd': end},
                       'features': [feature]})

    for m in URL_RE.finditer(text):
        add(m, {'$type': 'app.bsky.richtext.facet#link', 'uri': m.group()})
    for m in re.finditer(r'(?<!\S)#(\w+)', text):
        add(m, {'$type': 'app.bsky.richtext.facet#tag', 'tag': m.group(1)})
    return result


class OgParser(html.parser.HTMLParser):
    def __init__(self):
        super().__init__()
        self.og = {}

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        prop = a.get('property') or ''
        if tag == 'meta' and prop.startswith('og:') and 'content' in a:
            self.og.setdefault(prop, a['content'])


def link_card(url, token):
    # Bluesky does not make a card by itself, it is built from the Open
    # Graph data of the page.
    page, _ = fetch(url)
    parser = OgParser()
    parser.feed(page.decode('utf-8', 'replace'))
    og = parser.og
    card = {
        'uri': url,
        # "Release v1.0.0056 · owner/repo": the text of the post already
        # names the release.
        'title': og.get('og:title', url).rsplit(' · ', 1)[-1],
        # The release notes are too long for a card.
        'description': '',
    }
    if 'og:image' in og:
        try:
            image, mime = fetch(urllib.parse.urljoin(url, og['og:image']))
            if len(image) <= MAX_THUMB and mime.startswith('image/'):
                card['thumb'] = call('com.atproto.repo.uploadBlob', image,
                                     token, mime)['blob']
        except (OSError, ValueError, KeyError) as e:
            print(f'No image for the link card: {e}', file=sys.stderr)
    return {'$type': 'app.bsky.embed.external', 'external': card}


def main():
    if len(sys.argv) != 2:
        print('Usage: post_to_bluesky.py TEXT', file=sys.stderr)
        return 2
    text = sys.argv[1]
    try:
        handle = os.environ['BLUESKY_HANDLE']
        password = os.environ['BLUESKY_APP_PASSWORD']
    except KeyError as e:
        print(f'{e.args[0]} is not set', file=sys.stderr)
        return 1
    now = datetime.datetime.now(datetime.timezone.utc)
    record = {
        '$type': 'app.bsky.feed.post',
        'text': text,
        'facets': facets(text),
        'createdAt': now.isoformat(timespec='milliseconds')
                        .replace('+00:00', 'Z'),
    }
    try:
        session = call('com.atproto.server.createSession',
                       {'identifier': handle, 'password': password})
        token = session['accessJwt']
        m = URL_RE.search(text)
        if m:
            # Without the card the post is still made.
            try:
                record['embed'] = link_card(m.group(), token)
            except (OSError, ValueError, KeyError) as e:
                print(f'No link card: {e}', file=sys.stderr)
        res = call('com.atproto.repo.createRecord',
                   {'repo': session['did'],
                    'collection': 'app.bsky.feed.post',
                    'record': record},
                   token)
    except urllib.error.HTTPError as e:
        print(f'HTTP {e.code}: {e.read().decode()}', file=sys.stderr)
        return 1
    print(res['uri'])
    return 0


if __name__ == '__main__':
    sys.exit(main())
