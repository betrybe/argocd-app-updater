#!/bin/bash
set -ex

VERSION=v2.6.2 # Select desired TAG from https://github.com/argoproj/argo-cd/releases
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

export ARGOCD_SERVER=deploy.betrybe.com:443
app_name="$REPOSITORY-$ENVIRONMENT"
secrets=$1

if [[ -z "$secrets" ]]; then
  secrets=$(env | awk -F = '/^SECRET_/ {print $1}')
fi

secrets_list=""
for data in ${secrets}
do
  secret_key=$(echo $data | sed 's/'^SECRET_'//g')
  secrets_list="$secrets_list --helm-set secrets.$secret_key=${!data}"
done

argocd app set $app_name $secrets_list --grpc-web
argocd app wait $app_name --grpc-web
