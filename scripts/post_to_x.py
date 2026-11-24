#!/usr/bin/env python3
"""Post a text to X with the API v2, using the OAuth 1.0a user context.

Usage: post_to_x.py TEXT

The credentials are taken from the environment variables X_API_KEY,
X_API_SECRET, X_ACCESS_TOKEN and X_ACCESS_TOKEN_SECRET.
"""

import base64
import hashlib
import hmac
import json
import os
import secrets
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

URL = 'https://api.x.com/2/tweets'


def quote(s):
    # RFC 3986 percent-encoding, as OAuth 1.0a requires.
    return urllib.parse.quote(s, safe='')


def auth_header(api_key, api_secret, token, token_secret):
    params = {
        'oauth_consumer_key': api_key,
        'oauth_nonce': secrets.token_hex(16),
        'oauth_signature_method': 'HMAC-SHA1',
        'oauth_timestamp': str(int(time.time())),
        'oauth_token': token,
        'oauth_version': '1.0',
    }
    # A JSON body is not part of the signature.
    param_str = '&'.join(f'{quote(k)}={quote(v)}'
                         for k, v in sorted(params.items()))
    base = '&'.join(['POST', quote(URL), quote(param_str)])
    key = f'{quote(api_secret)}&{quote(token_secret)}'
    digest = hmac.new(key.encode(), base.encode(), hashlib.sha1).digest()
    params['oauth_signature'] = base64.b64encode(digest).decode()
    return 'OAuth ' + ', '.join(f'{quote(k)}="{quote(v)}"'
                                for k, v in sorted(params.items()))


def main():
    if len(sys.argv) != 2:
        print('Usage: post_to_x.py TEXT', file=sys.stderr)
        return 2
    try:
        header = auth_header(os.environ['X_API_KEY'],
                             os.environ['X_API_SECRET'],
                             os.environ['X_ACCESS_TOKEN'],
                             os.environ['X_ACCESS_TOKEN_SECRET'])
    except KeyError as e:
        print(f'{e.args[0]} is not set', file=sys.stderr)
        return 1
    req = urllib.request.Request(
        URL,
        data=json.dumps({'text': sys.argv[1]}).encode(),
        headers={'Authorization': header,
                 'Content-Type': 'application/json'},
        method='POST')
    try:
        with urllib.request.urlopen(req, timeout=30) as res:
            print(res.read().decode())
    except urllib.error.HTTPError as e:
        print(f'HTTP {e.code}: {e.read().decode()}', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
