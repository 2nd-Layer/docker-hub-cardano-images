FROM perlur/centos-base AS builder

ENV JORMUNGANDR_VERSION="v0.7.1"

RUN yum update -y
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    source $HOME/.cargo/env && \
    rustup install stable && \
    rustup default stable
RUN yum install -y git gcc openssl-devel
WORKDIR /usr/src
RUN git clone --recurse-submodules https://github.com/input-output-hk/jormungandr
WORKDIR jormungandr
RUN git fetch --tags
RUN git checkout $JORMUNGANDR_VERSION
RUN source $HOME/.cargo/env && cargo install --root /usr/local --path jormungandr
RUN source $HOME/.cargo/env && cargo install --root /usr/local --path jcli

FROM perlur/centos-base

MAINTAINER "Mark Stopka <mark.stopka@perlur.cloud>"

ENV SERVICE_NAME "cardano-jormungandr"

RUN yum update -y && \
    yum clean all && \
    dnf clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /var/cache/dnf

EXPOSE 3000

COPY --from=builder /usr/local/bin/jormungandr /usr/local/bin/
COPY --from=builder /usr/local/bin/jcli /usr/local/bin/
COPY usr/local/bin/docker-entrypoint.sh /usr/local/bin/

RUN mkdir -p /srv/cardano/jormungandr/

RUN useradd -b /srv/cardano/jormungandr/ \
            -c "Jormungandr node user" \
            -M \
            -r \
            -s /bin/nologin \
            jormungandr

RUN chown jormungandr.jormungandr /srv/cardano/jormungandr/
USER jormungandr

RUN mkdir /srv/cardano/jormungandr/{etc,log,storage}/
RUN mkdir /srv/cardano/jormungandr/etc/secrets/

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]