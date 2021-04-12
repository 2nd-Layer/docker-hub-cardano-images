FROM perlur/centos-rust-rustup AS builder

ENV JORMUNGANDR_VERSION="master"

RUN yum update -y && \
    yum install -y git-core gcc openssl-devel
RUN source $HOME/.cargo/env && \
    rustup default stable && \
    rustup self update
WORKDIR /usr/src
RUN git clone --recurse-submodules https://github.com/input-output-hk/jormungandr
WORKDIR jormungandr
RUN git fetch --tags
RUN git checkout $JORMUNGANDR_VERSION
RUN git submodule update --init --recursive
RUN source $HOME/.cargo/env && \
    cargo install --locked --root /usr/local --path jormungandr
RUN source $HOME/.cargo/env && \
    cargo install --locked --root /usr/local --path jcli

FROM perlur/centos-base

MAINTAINER "Mark Stopka <mark.stopka@perlur.cloud>"

ENV SERVICE_NAME "cardano-jormungandr"

RUN yum update -y && \
    yum install -y jq && \
    yum clean all && \
    dnf clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /var/cache/dnf

EXPOSE 3000

COPY --from=builder /usr/local/bin/jormungandr /usr/local/bin/
COPY --from=builder /usr/local/bin/jcli /usr/local/bin/
COPY usr/local/lib/* /usr/local/lib/
COPY usr/local/bin/* /usr/local/bin/

RUN mkdir -p /srv/cardano/

RUN useradd -c "Jormungandr node user" \
            -d /srv/cardano/jormungandr/ \
            -m \
            -r \
            -s /bin/nologin \
            jormungandr

USER jormungandr

RUN mkdir /srv/cardano/jormungandr/{etc,log,storage}/
RUN mkdir /srv/cardano/jormungandr/etc/secrets/

WORKDIR /srv/cardano/jormungandr/

COPY srv/cardano/jormungandr/ /srv/cardano/jormungandr/

RUN jcli auto-completion bash ~/etc/

HEALTHCHECK --interval=1s --timeout=2s CMD jcli-node-stats healthcheck || exit 1

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
