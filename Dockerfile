FROM argoproj/argocd:v2.6.2 as builder

FROM ubuntu:22.04

ENV ARGOCD_SERVER=deploy.betrybe.com:443

WORKDIR /argo

COPY --from=builder /usr/local/bin/argocd /usr/local/bin/argocd

COPY ./update_params.sh /argo/update_params.sh

RUN chmod +x /argo/update_params.sh

ENTRYPOINT [ "/argo/update_params.sh" ]
