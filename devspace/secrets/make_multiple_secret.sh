#!/bin/bash
set -e

NAMESPACE='testing'
ENVIRONMENT='production'

read -p "MySQL-Password:" MYSQL_PASSWORD
read -p "MySQL-Replication-Password:" MYSQL_REPLICATION_PASSWORD
read -p "MySQL-Root-Password:" MYSQL_ROOT_PASSWORD

kubectl -n $NAMESPACE create secret generic mysql-credentials \
  --dry-run=client \
  --from-literal=mysql-password="$MYSQL_PASSWORD" \
  --from-literal=mysql-replication-password="$MYSQL_REPLICATION_PASSWORD" \
  --from-literal=mysql-root-password="$MYSQL_ROOT_PASSWORD" \
  -o json | \
  kubeseal \
    $SCOPE \
    --controller-namespace kube-system \
    > mysql-credentials.json
