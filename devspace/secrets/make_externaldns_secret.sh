#!/bin/bash
set -e

NAMESPACE='testing'
ENVIRONMENT='production'

read -p "cloudflare_api_token:" CF_API_TOKEN
read -p "cloudflare_api_key:" CF_API_KEY

kubectl -n $NAMESPACE create secret generic external-dns \
  --dry-run=client \
  --from-literal=cloudflare_api_token="$CF_API_TOKEN" \
  --from-literal=cloudflare_api_key="$CF_API_KEY" \
  -o json | \
  kubeseal \
    $SCOPE \
    --controller-namespace kube-system \
    > external-dns.json
