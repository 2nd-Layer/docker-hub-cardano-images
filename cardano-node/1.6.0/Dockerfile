FROM perlur/centos-haskell-stack AS builder

ENV CARDANO_NODE_VERSION="1.6.0"

RUN yum update -y && \
    yum install -y openssl-devel systemd-devel zlib-devel
WORKDIR /usr/src
RUN git clone --recurse-submodules https://github.com/input-output-hk/cardano-node
WORKDIR cardano-node
RUN git fetch --tags
RUN git checkout ${CARDANO_NODE_VERSION}
RUN git cherry-pick -m 1 -n 6308e1bf30b76d54986aa0dff74e38b803e6a68e

# Ugly workaround for vty-5.25.1
RUN ln -s /usr/lib64/libtinfo.so.6 /usr/lib64/libtinfo.so
RUN stack install \
      --flag cardano-node:-with_wallet_client \
      --flag cardano-node:-with_chairman \
      --local-bin-path=/usr/local/bin

FROM perlur/centos-base

MAINTAINER "Mark Stopka <mark.stopka@perlur.cloud>"

ENV SERVICE_NAME "cardano-node"

RUN yum update -y && \
    yum clean all && \
    dnf clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /var/cache/dnf

EXPOSE 3000

COPY --from=builder /usr/local/bin/cardano-node /usr/local/bin/
COPY --from=builder /usr/local/bin/cardano-cli /usr/local/bin/
COPY usr/local/lib/* /usr/local/lib/
COPY usr/local/bin/* /usr/local/bin/

RUN mkdir -p /srv/cardano/

RUN useradd -c "Cardano node user" \
            -d /srv/cardano/cardano-node/ \
            -m \
            -r \
            -s /bin/nologin \
            cardano-node

USER cardano-node

RUN mkdir /srv/cardano/cardano-node/{etc,log,storage}/
RUN mkdir /srv/cardano/cardano-node/etc/secrets/

WORKDIR /srv/cardano/cardano-node/

HEALTHCHECK --interval=5s --timeout=1s CMD jcli-node-stats || exit 1

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
