FROM deepcortex/scala-python3:latest

ARG BUILD_DATE
ARG VCS_REF
ARG IMAGE_VERSION

ENV PACKER_VERSION=1.0.4
ENV PACKER_SHA256SUM=646da085cbcb8c666474d500a44d933df533cf4f1ff286193d67b51372c3c59e

RUN apt-get update && \
    apt-get install -y unzip && \
    apt-get install -y uuid-runtime &&

RUN pip install awscli --upgrade   

ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip ./
ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_SHA256SUMS ./

RUN sed -i '/.*linux_amd64.zip/!d' packer_${PACKER_VERSION}_SHA256SUMS && \
    sha256sum -c --strict packer_${PACKER_VERSION}_SHA256SUMS && \
    unzip packer_${PACKER_VERSION}_linux_amd64.zip -d /bin && \
    rm -f packer_${PACKER_VERSION}_linux_amd64.zip && \
    echo "packer version - $(packer --version)"

ENV TERRAFORM_VERSION=0.11.0
ENV TERRAFORM_SHA256SUM=402b4333792967986383670134bb52a8948115f83ab6bda35f57fa2c3c9e9279

RUN wget --quiet https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    echo "${TERRAFORM_SHA256SUM}  terraform_${TERRAFORM_VERSION}_linux_amd64.zip" > terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    sha256sum -c --strict terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    echo "terraform version - $(terraform --version)"

WORKDIR /opt/deploy

COPY ansible ansible
COPY packer packer
COPY scripts scripts
COPY terraform terraform
COPY build.sh build.sh
COPY destroy.sh destroy.sh
COPY packer.sh packer.sh
COPY terraform.sh terraform.sh
COPY terraform_init_backend.sh terraform_init_backend.sh

ENTRYPOINT ["/bin/bash", "/opt/deploy/build.sh"]

LABEL maintainer="sergey.semichev@sentrana.com" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="DeepCortex" \
      org.label-schema.description="DeepCortex is the world’s first cloud based, automated platform for doing the entire end-to-end Data Science process" \
      org.label-schema.url="http://www.deepcortex.ai" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.version=$IMAGE_VERSION \
      org.label-schema.vcs-url="https://github.com/deepcortex/scorpius" \
      org.label-schema.vendor="DeepCortex" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.docker.cmd="docker run --rm -it deepcortex/scorpius-deployment /bin/bash"



