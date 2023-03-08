#!/bin/bash
set -e

app_name="$REPOSITORY-$ENVIRONMENT"
secrets=$1

echo "======= ArgoCD Updater ======="
echo ""
echo "...Aguardando o ArgoCD sincronizar a aplicação $app_name"
echo "Para mais detalhes (logs, debug) sobre o status do deploy acesse https://deploy.betrybe.com"
echo ""
echo "======= ArgoCD Updater ======="

curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/$ARGOCD_VERSION/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

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
  echo "::group::Alterando secrets/envvars"
  argocd app set $app_name $secrets_list --grpc-web
  echo "::endgroup::"
fi

# When is rollback, gets the last previous production image and set to the application
if [[ $ACTION == "rollback" ]]; then
  lastPreviousPushedImage=$(aws ecr describe-images --repository-name dev-tools \
    --filter tagStatus=TAGGED \
    --query "reverse(sort_by(imageDetails[*].{imageTags: imageTags[?starts_with(@, 'production')], imagePushedAt: imagePushedAt}, &imagePushedAt))[1:2].imageTags[0]" \
    --no-verify-ssl | jq '.[0]' | sed -e "s/\"//g")
  export IMAGE_TAG=$lastPreviousPushedImage
fi

if [[ ! -z "$IMAGE_TAG" ]]; then
  echo "::group::Alterando image.tag"
  echo "Updating image to tag: $IMAGE_TAG"
  argocd app set $app_name --helm-set image.tag=$IMAGE_TAG --grpc-web
  echo "::endgroup::"
fi

echo "::group::Sincronizando"
argocd app wait $app_name --grpc-web
echo ""
echo "Para mais detalhes (logs, debug) sobre o status do deploy acesse https://deploy.betrybe.com"
echo "::endgroup::"
