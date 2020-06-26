FROM perlur/centos-haskell-ghcup AS builder

ENV CABAL_VERSION="3.2.0.0"
ENV GHC_VERSION="8.6.5"

ENV CARDANO_NODE_VERSION="1.14.0"

RUN yum update -y && \
    yum install -y libsodium-devel openssl-devel systemd-devel zlib-devel
RUN ghcup install-cabal ${CABAL_VERSION}
RUN ghcup install ${GHC_VERSION} && \
    ghcup set ${GHC_VERSION}

WORKDIR /usr/src
RUN git clone --recurse-submodules https://github.com/input-output-hk/cardano-node
WORKDIR cardano-node
RUN git fetch --tags
RUN git checkout ${CARDANO_NODE_VERSION}
COPY cabal.project.local ./

# Ugly workaround for vty-5.25.1
RUN ln -s /usr/lib64/libtinfo.so.6 /usr/lib64/libtinfo.so
RUN cabal update
RUN cabal install cardano-cli \
      --installdir=/usr/local/bin \
      --install-method=copy \
      -f-systemd \
      -f -external-libsodium-vrf
RUN cabal install cardano-node \
      --install-method=copy \
      --installdir=/usr/local/bin \
      -f-systemd  \
      -f -external-libsodium-vrf

FROM perlur/centos-base

MAINTAINER "Mark Stopka <mark.stopka@perlur.cloud>"

ENV SERVICE_NAME "cardano-node"

RUN yum update -y && \
    yum install -y libsodium && \
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

RUN mkdir -p /var/run/cardano/
RUN chown cardano-node.cardano-node /var/run/cardano/
USER cardano-node

RUN mkdir /srv/cardano/cardano-node/{etc,log,storage}/
RUN mkdir /srv/cardano/cardano-node/etc/secrets/

WORKDIR /srv/cardano/cardano-node/

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
