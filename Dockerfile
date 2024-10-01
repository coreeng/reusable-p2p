FROM ubuntu:24.04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG TARGETPLATFORM

# Ensure TARGETPLATFORM is not empty
RUN if [ "${TARGETPLATFORM}" = "" ] ; then \
        echo "TARGETPLATFORM is empty, ensure you have docker-buildx installed, aborting build." ; \
        exit 1 ; \
    fi

# Ensure the FROM image platform matches the build target platform
RUN DETECTEDPLATFORM="$(uname -o | sed -e "s/GNU\/Linux/linux/")/$(uname -m | sed -e "s/aarch64/arm64/" -e "s/x86_64/amd64/")" ; \
	if [ "${TARGETPLATFORM}" != "${DETECTEDPLATFORM}" ] ; then \
		echo "TARGETPLATFORM is '${TARGETPLATFORM}' but FROM image is ${DETECTEDPLATFORM}, aborting build." ; \
		exit 1 ; \
	fi

WORKDIR /app

# Install dependencies
# hadolint ignore=DL3008
RUN --mount=type=cache,target=/var/cache/apt \
 apt-get update \
 && apt-get install --no-install-recommends -y \
	curl \
	dnsutils \
	file \
	git \
	golang \
	gpg \
	jq \
	lsb-release \
	make \
	python3 \
	python3-pip \
	python3-venv \
	rsync \
	skopeo \
	unzip \
	vim \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install gcloud CLI
ARG GCLOUD_CLI_VERSION=489.0.0
ENV PATH=/opt/google-cloud-sdk/bin:$PATH
VOLUME ["/root/.config/gcloud"]
RUN curl -Lso google-cloud-cli.tgz "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${GCLOUD_CLI_VERSION}-linux-$(uname -m | sed -e "s/aarch64/arm/").tar.gz" \
 && tar zxf google-cloud-cli.tgz --directory /opt/ \
 && rm google-cloud-cli.tgz \
 && gcloud config set core/disable_usage_reporting true \
 && gcloud config set component_manager/disable_update_check true \
 && gcloud config set metrics/environment github_docker_image \
 && gcloud components install beta gke-gcloud-auth-plugin --quiet \
 && $(gcloud info --format="value(basic.python_location)") -m pip install numpy \
 && gcloud --version



# Install kubectl
ARG KUBECTL_VERSION=1.29.7
RUN curl -Lso kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/$(uname -m | sed -e "s/aarch64/arm64/" -e "s/x86_64/amd64/")/kubectl" \
 && install -o root -g root -m 0755 kubectl /usr/local/bin/ \
 && rm kubectl \
 && kubectl version --client=true

# Install kubectl-hns
ARG KUBECTL_HNS_VERSION=1.1.0
RUN curl -Lso kubectl-hns "https://github.com/kubernetes-sigs/hierarchical-namespaces/releases/download/v${KUBECTL_HNS_VERSION}/kubectl-hns_linux_$(uname -m | sed -e "s/aarch64/arm64/" -e "s/x86_64/amd64/")" \
 && install -o root -g root -m 0755 kubectl-hns /usr/local/bin/ \
 && rm kubectl-hns \
 && kubectl hns version

# Install helm
ARG HELM_VERSION=3.15.4
RUN curl -Lso helm.tgz "https://get.helm.sh/helm-v${HELM_VERSION}-linux-$(uname -m | sed -e "s/aarch64/arm64/" -e "s/x86_64/amd64/").tar.gz" \
 && tar zxf helm.tgz --strip-components=1 "linux-$(uname -m | sed -e "s/aarch64/arm64/" -e "s/x86_64/amd64/")/helm" \
 && install -o root -g root -m 0755 helm /usr/local/bin/ \
 && rm helm.tgz helm \
 && helm version --short


# Install hadolint
ARG HADOLINT_VERSION=2.12.0
RUN curl -Lso hadolint "https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-Linux-$(uname -m | sed -e "s/aarch64/arm64/")" \
 && install -o root -g root -m 0755 hadolint /usr/local/bin \
 && rm -rf hadolint \
 && hadolint --version

# Install yq
ARG YQ_VERSION=4.44.3
RUN curl -Lso yq "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_$(uname -m | sed -e "s/aarch64/arm64/" -e "s/x86_64/amd64/")" \
 && install -o root -g root -m 0755 yq /usr/local/bin/ \
 && rm yq \
 && yq --version


RUN CORECTL_VERSION=$(curl -s https://api.github.com/repos/coreeng/corectl/releases/latest | grep '"tag_name":' | cut -d'"' -f4) \
    && curl -L "https://github.com/coreeng/corectl/releases/download/${CORECTL_VERSION}/corectl_Linux_x86_64.tar.gz" -o corectl.tar.gz \ 
    && tar -xzf corectl.tar.gz  \
    && chmod +x corectl \
    && mv corectl /usr/local/bin/ \
    && rm corectl.tar.gz 

WORKDIR /app

RUN curl -fsSL https://get.docker.com | sh 

# Set source date epoch and release revision and version
ARG SOURCE_DATE_EPOCH
ENV SOURCE_DATE_EPOCH=${SOURCE_DATE_EPOCH}

ARG RELEASE_REVISION=undefined
ENV RELEASE_REVISION=${RELEASE_REVISION}

ARG RELEASE_VERSION=0.0.0-undefined
ENV RELEASE_VERSION=${RELEASE_VERSION}
