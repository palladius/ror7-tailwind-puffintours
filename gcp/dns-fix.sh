#!/bin/bash

set -euo pipefail

# https://cloud.google.com/run/docs/mapping-custom-domains#gcloud
DOMAIN=pt.palladius.it
DOMAIN2=tours.palladius.it
SERVICE=puffintours-prod
REGION=europe-west1
PROJECT_ID=puffin-tours

gcloud config set project $PROJECT_ID
# strebel wisdom
HELLO_US_URI=$(gcloud run services describe $SERVICE --region $REGION --format 'value(status.url)')
purple "Strebel wisdom: $HELLO_US_URI"

# gcloud --project puffin-tours \
#     beta run domain-mappings create \
#     --service puffintours-prod \
#     --domain puffintours.palladius.it \
#     --region europe-west1

# already exists in this region


# gcloud --project puffin-tours \
#     beta run domain-mappings create \
#     --service puffintours-prod \
#     --domain $DOMAIN2 \
#     --region europe-west1

#gcloud beta run domain-mappings delete --service SERVICE --domain DOMAIN
gcloud --project $PROJECT_ID beta run domain-mappings describe --domain $DOMAIN --region $REGION

echo 'Ora vai su https://console.cloud.google.com/net-services/dns/zones/palladius-it/details?inv=1&invt=AbkzkA&project=ric-cccwiki e aggiungi pt,CNAME,ghs.googlehosted.com.'
# WOW

echo ora manca solo laudeince

# sembra utile solo se NON lo vuoi unauthed. autenticato mi sembra inutile..
# https://cloud.google.com/run/docs/securing/managing-access?_gl=1*5s5c92*_ga*MTIyMTMyMjE0NS4xNzI3NTYxODE1*_ga_WH2QY8WWF5*MTczNDg0NTkyMy4yNi4xLjE3MzQ4Nzg3MDguNC4wLjA.
echodo gcloud run services update $SERVICE --add-custom-audiences=pt.palladius.it,https://pt.palladius.it,tours.palladius.it --region $REGION

# test authenticated: https://medium.com/google-cloud/authentication-for-multi-regional-cloud-run-deployments-with-custom-audiences-512dcc1c16ec
ID_TOKEN="$(gcloud auth print-identity-token)"

yellow "1. Testing authenticated request to $HELLO_US_URI"
curl $HELLO_US_URI -H "Authorization: Bearer $ID_TOKEN"

yellow "2. Testing authenticated request to https://pt.palladius.it"
curl https://pt.palladius.it -H "Authorization: Bearer $ID_TOKEN"

# echo Strebel magic:
# echo $ID_TOKEN | jq -R 'split(".") | .[1] | @base64d | fromjson'
