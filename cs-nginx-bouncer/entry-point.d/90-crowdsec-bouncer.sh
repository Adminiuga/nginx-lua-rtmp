#!/bin/sh

set -e

CROWDSEC_BOUNCER_CONFIG="${BOUNCER_CONFIG:-/etc/crowdsec/bouncers/crowdsec-nginx-bouncer.conf}"

params='
API_KEY
API_URL
'

for var in $params; do
    eval "value=\$CROWDSEC_$var"
    if [ -n "$value" ]; then
        sed -i "s,${var}.*,${var}=${value}," "$CROWDSEC_BOUNCER_CONFIG"
    fi
done