#!/bin/bash
set -e

app_name="$REPOSITORY-$ENVIRONMENT"
secrets=$1
if [[ -z "$secrets" ]]; then
  secrets=$(env | awk -F = '/^SECRET_/ {print $1}')
fi

secrets_list=""
for data in ${secrets}
do
  secret_key=$(echo $data | sed 's/'^SECRET_'//g')
  argocd app set "$app_name" --helm-set "secrets.$secret_key=${data}" --auth-token "$ARGOCD_TOKEN"
done

argocd app wait "$app_name" --auth-token "$ARGOCD_TOKEN"
