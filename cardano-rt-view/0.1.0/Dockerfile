FROM perlur/centos-haskell-ghcup AS builder

ENV CABAL_VERSION="3.2.0.0"
ENV GHC_VERSION="8.10.2"

ENV CARDANO_RTVIEW_VERSION="0.1.0"

RUN yum update -y && \
    yum install -y pkgconf systemd-devel zlib-devel
RUN ghcup install cabal ${CABAL_VERSION}
RUN ghcup install ghc ${GHC_VERSION} && \
    ghcup set ghc ${GHC_VERSION}

WORKDIR /usr/src
RUN git clone --recurse-submodules https://github.com/input-output-hk/cardano-rt-view
WORKDIR /usr/src/cardano-rt-view
RUN git fetch --all
RUN git checkout ${CARDANO_RTVIEW_VERSION}

RUN cabal v2-update
RUN cabal v2-install exe:cardano-rt-view \
      --ghc-options="-Wno-error=unused-imports" \
      --installdir=/usr/local/bin \
      --install-method=copy \
      -j

FROM perlur/centos-base

LABEL maintainer="Mark Stopka <mark.stopka@perlur.cloud>"

ENV SERVICE_NAME "cardano-rt-view"

RUN yum update -y && \
    yum clean all && \
    dnf clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /var/cache/dnf

EXPOSE 8080

COPY --from=builder /usr/local/bin/cardano-rt-view /usr/local/bin/
COPY --from=builder /usr/src/cardano-rt-view/static/ /usr/local/share/cardano-rt-view/static/
#COPY usr/local/lib/* /usr/local/lib/
COPY usr/local/bin/* /usr/local/bin/

RUN mkdir -p /srv/cardano/

RUN groupadd -r cardano-node
RUN useradd -c "Cardano RT View" \
            -G cardano-node \
            -d /srv/cardano/cardano-rt-view/ \
            -m \
            -r \
            -s /bin/nologin \
            cardano-rt-view

RUN mkdir -p /var/run/cardano-rt-view/
RUN chown cardano-rt-view.cardano-node /var/run/cardano-rt-view/
USER cardano-rt-view

RUN mkdir /srv/cardano/cardano-rt-view/etc/

WORKDIR /srv/cardano/cardano-rt-view/

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
