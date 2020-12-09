#!/bin/bash
set -e

NAMESPACE='testing'
ENVIRONMENT='production'

read -p "MySQL-Password:" MYSQL_PASSWORD
read -p "MySQL-Replication-Password:" MYSQL_REPLICATION_PASSWORD
read -p "MySQL-Root-Password:" MYSQL_ROOT_PASSWORD
read -p "MySQL-Password-For-WP:" WP_DATABASE_PASSWORD
read -p "WP-Password:" WP_PASSWORD


kubectl -n $NAMESPACE create secret generic mysql-credentials \
  --dry-run=client \
  --from-literal=mysql-password="$MYSQL_PASSWORD" \
  --from-literal=mysql-replication-password="$MYSQL_REPLICATION_PASSWORD" \
  --from-literal=mysql-root-password="$MYSQL_ROOT_PASSWORD" \
  --from-literal=mariadb-password="$WP_DATABASE_PASSWORD" \
  --from-literal=wordpress-password="$WP_PASSWORD" \
  -o json | \
  kubeseal \
    $SCOPE \
    --controller-namespace kube-system \
    > credentials.json
