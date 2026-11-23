#!/bin/bash
set -e

_dir="$(dirname "$0")"
source "$_dir/config.sh"

AUTH_ID=$(curl -s -G "https://$API_HOST/dnsmgr" \
  --data-urlencode "out=json" \
  --data-urlencode "func=auth" \
  --data-urlencode "username=$API_USERNAME" \
  --data-urlencode "password=$API_PASSWORD" \
| python3 -c 'import sys,json; print(json.load(sys.stdin)["doc"]["auth"]["$id"])')

RECORD="_acme-challenge"

curl -fsS -G "https://$API_HOST/dnsmgr" \
  --data-urlencode "out=json" \
  --data-urlencode "auth=$AUTH_ID" \
  --data-urlencode "func=domain.record.edit" \
  --data-urlencode "plid=$CERTBOT_DOMAIN" \
  --data-urlencode "name=$RECORD" \
  --data-urlencode "rtype=txt" \
  --data-urlencode "value=$CERTBOT_VALIDATION" \
  --data-urlencode "ttl=60" \
  --data-urlencode "sok=ok" > /dev/null

DOMAIN="$RECORD.$CERTBOT_DOMAIN"

echo "Waiting DNS propagation (max 20s)..."

for i in {1..5}; do
    RESULT=$(dig +short TXT "$DOMAIN" @1.1.1.1 | tr -d '"')

    if echo "$RESULT" | grep -q "$CERTBOT_VALIDATION"; then
        echo "DNS propagated"
        exit 0
    fi

    echo "Not ready yet... ($i/5)"
    sleep 5
done

echo "DNS NOT propagated in time"
exit 1
