FROM registry.fedoraproject.org/fedora:29 as cfsslbuild

RUN dnf -y install golang
RUN go get -u github.com/cloudflare/cfssl/cmd/cfssl
RUN go get -u github.com/cloudflare/cfssl/cmd/cfssljson


FROM registry.fedoraproject.org/fedora:29

ENV TF_VER=0.11.11
ENV YAML2JSON_VER=1.3
ENV KUBECTL_VER=1.13.3
ENV HELM_VER=2.12.3

RUN dnf -y install unzip jq git httpd-tools
RUN dnf clean all

# terraform
RUN curl -L -o terraform.zip https://releases.hashicorp.com/terraform/${TF_VER}/terraform_${TF_VER}_linux_amd64.zip
RUN unzip -d /usr/local/bin terraform.zip
RUN rm -f terraform.zip

# kubectl
RUN curl -L -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VER}/bin/linux/amd64/kubectl
RUN chmod +x /usr/local/bin/kubectl

# helm
RUN curl -L https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VER}-linux-amd64.tar.gz | tar xzvf -
RUN mv linux-amd64/helm /usr/local/bin/
RUN rm -rf linux_amd64

# cfssl
COPY --from=cfsslbuild /root/go/bin/cfssl /usr/local/bin/cfssl
COPY --from=cfsslbuild /root/go/bin/cfssljson /usr/local/bin/cfssljson

# yaml2json
RUN curl -L -o /usr/local/bin/yaml2json https://github.com/bronze1man/yaml2json/releases/download/v${YAML2JSON_VER}/yaml2json_linux_amd64
RUN chmod +x /usr/local/bin/yaml2json

ENTRYPOINT [ "/bin/bash" ]