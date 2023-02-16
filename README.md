# ArgoCD Application Updater

Esta GitHub Action é utilizada para fazer atualizar secrets do Helm das aplicações em que o deploy é gerenciado pelo [ArgoCD](https://deploy.betrybe.com) da Trybe.
Também pode ser usado para usar uma imagem customizada (diferente daquela definida no `Dockerfile` do projeto).

> Obs.: A envvar no kubernetes ficará sem este prefixo `SECRET_`. Ex.: `SECRET_MY_ENV` será `MY_ENV`.

```yaml
- name: Update ArgoCD application
  uses: betrybe/argocd-app-updater@main
  env:
    SECRET_MY_ENVVAR: ${{ secrets.MINHA_ENVVAR }}
    SECRET_DATABASE_URL: ${{ secrets.DATABASE_STAGING_URL }}
    SECRET_MY_CUSTOM_ENV: "custom value"
    # Por default irá usar a imagem que está no AWS ECR
    # O build desta imagem foi feito com base no Dockerfile presente na raiz do repositório do projeto
    # A tag, por default é o ambiente do projeto (staging, homologation)
    IMAGE_TAG: "v2.0.0"
    IMAGE_REPOSITORY: "registry.hub.docker.com/REPO/IMAGE"
```
