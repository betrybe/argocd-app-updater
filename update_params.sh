#!/bin/bash
set -e

secrets=$1
if [[ -z "$secrets" ]]; then
  secrets=$(env | awk -F = '/^SECRET_/ {print $1}')
fi

secrets_list=""
for data in ${secrets}
do
  NAME=$(echo $data | sed 's/'^SECRET_'//g')
  argocd app set $REPOSITORY --helm-set "secrets.$NAME=${data}" --auth-token $ARGOCD_TOKEN
done

argocd app wait $REPOSITORY --auth-token $ARGOCD_TOKEN
