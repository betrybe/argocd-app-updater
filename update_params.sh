#!/bin/bash
set -e

curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/$ARGOCD_VERSION/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

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

if [[ -z "$secrets_list" ]]; then
  argocd app set $app_name $secrets_list --grpc-web
fi

if [[ -z "$IMAGE_TAG" ]] && {
  echo "Updating image to tag: $IMAGE_TAG"
  argocd app set $app_name --helm-set image.tag=$IMAGE_TAG --grpc-web
}

echo "======= ArgoCD Updater ======="
echo ""
echo "...Aguardando o ArgoCD sincronizar a aplicação"
echo "Para mais detalhes (logs, debug) sobre o status do deploy acesse https://deploy.betrybe.com"
echo ""
echo "======= ArgoCD Updater ======="

argocd app wait $app_name --grpc-web
