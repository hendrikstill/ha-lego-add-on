#!/usr/bin/env bashio
DOMAIN="test.still.wtf" #$(bashio::config 'domain')
EMAIL="gamma32@gmail.com" #$(bashio::config 'email')
SYS_CERTFILE="fullchain.pem"
SYS_KEYFILE="privkey.pem"
LEGO_OPTS="--server=https://acme-staging-v02.api.letsencrypt.org/directory"

function le_create() {
    bashio::log.info "Create certificate for domain: $(echo -n "${DOMAIN}")"
    lego $LEGO_OPTS -a --dns scaleway --email $EMAIL --domains $DOMAIN run
}

function le_renew() {
    bashio::log.info "Try to renew certificate for domain: $(echo -n "${DOMAIN}")"
    lego $LEGO_OPTS -a --dns scaleway --email $EMAIL --domains $DOMAIN renew
}

function deploy_certs() {
    bashio::log.info "Deploy certificates"
    cp -f ".lego/certificates/${DOMAIN}.crt" "/ssl/$SYS_CERTFILE"
    cp -f ".lego/certificates/${DOMAIN}.key" "/ssl/$SYS_KEYFILE"
}

while true; do
    if [[ ! -f ".lego/certificates/${DOMAIN}.key" ]]; then
        le_create;
    else
        le_renew;
    fi
    deploy_certs;
    sleep 10;
done