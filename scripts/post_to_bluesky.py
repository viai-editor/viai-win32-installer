#!/usr/bin/env python3
"""Post a text to Bluesky, with its URLs and hashtags as links.

Usage: post_to_bluesky.py TEXT

The account is taken from the environment variables BLUESKY_HANDLE and
BLUESKY_APP_PASSWORD (an app password, not the account password).
"""

import datetime
import json
import os
import re
import sys
import urllib.error
import urllib.request

PDS = 'https://bsky.social/xrpc/'


def call(method, body, token=None):
    headers = {'Content-Type': 'application/json'}
    if token:
        headers['Authorization'] = f'Bearer {token}'
    req = urllib.request.Request(PDS + method,
                                 data=json.dumps(body).encode(),
                                 headers=headers, method='POST')
    with urllib.request.urlopen(req, timeout=30) as res:
        return json.load(res)


def facets(text):
    # Bluesky makes nothing a link by itself.  A facet gives the range in
    # UTF-8 bytes.
    result = []

    def add(m, feature):
        start = len(text[:m.start()].encode())
        end = len(text[:m.end()].encode())
        result.append({'index': {'byteStart': start, 'byteEnd': end},
                       'features': [feature]})

    for m in re.finditer(r'https?://\S+', text):
        add(m, {'$type': 'app.bsky.richtext.facet#link', 'uri': m.group()})
    for m in re.finditer(r'(?<!\S)#(\w+)', text):
        add(m, {'$type': 'app.bsky.richtext.facet#tag', 'tag': m.group(1)})
    return result


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
        res = call('com.atproto.repo.createRecord',
                   {'repo': session['did'],
                    'collection': 'app.bsky.feed.post',
                    'record': record},
                   session['accessJwt'])
    except urllib.error.HTTPError as e:
        print(f'HTTP {e.code}: {e.read().decode()}', file=sys.stderr)
        return 1
    print(res['uri'])
    return 0


if __name__ == '__main__':
    sys.exit(main())
