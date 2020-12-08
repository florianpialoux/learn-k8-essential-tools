#!/bin/bash
set -e

NAMESPACE='testing'
ENVIRONMENT='production'

read -p "KEY: " KEY
read -p "VALUE: " VALUE

mkdir -p secrets
KEY_T=$(echo "$KEY" | tr _ - | tr '[:upper:]' '[:lower:]')
kubectl -n $NAMESPACE create secret generic $KEY_T \
  --dry-run=client \
  --from-literal=$KEY="$VALUE" \
  -o json | \
  kubeseal \
    $SCOPE \
    --controller-namespace kube-system \
    > $KEY.json

echo -e "\nExample secret key reference:"
echo "env:"
echo "- name: $KEY"
echo "  valueFrom:"
echo "    secretKeyRef:"
echo "      name: $KEY_T"
echo "      key: $KEY"
