#!/bin/bash
set -e
#exec > /dev/null 2>&1
source "$(dirname "$0")/config.sh"

AUTH_ID=$(curl -s -G "https://$API_HOST/dnsmgr" \
  --data-urlencode "out=json" \
  --data-urlencode "func=auth" \
  --data-urlencode "username=$API_USERNAME" \
  --data-urlencode "password=$API_PASSWORD" \
| python3 -c 'import sys,json; print(json.load(sys.stdin)["doc"]["auth"]["$id"])')

RECORD="_acme-challenge"
DOMAIN="$RECORD.$CERTBOT_DOMAIN."
KEY="$DOMAIN TXT  $CERTBOT_VALIDATION"

echo "Deleting $KEY"

curl -fsS -G "https://$API_HOST/dnsmgr" \
--data-urlencode "out=json" \
--data-urlencode "auth=$AUTH_ID" \
--data-urlencode "func=domain.record.delete" \
--data-urlencode "elid=$KEY" \
--data-urlencode "plid=$CERTBOT_DOMAIN" \
--data-urlencode "sok=ok" > /dev/null

echo "[DONE]"
