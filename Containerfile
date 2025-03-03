FROM ubuntu:25.04 as builder

ARG SOFTHSM_VER=develop

RUN apt update \
    && apt install -y \
    git-core \
    automake \
    autoconf \
    libtool \
    libssl-dev \
    build-essential \
    cmake \
    pkg-config \
    libseccomp-dev \
    && apt clean

RUN git clone https://github.com/bukka/pkcs11-proxy.git /pkcs11-proxy_tmp \
    && git clone https://github.com/opendnssec/SoftHSMv2.git /SoftHSM_tmp

WORKDIR /SoftHSM_tmp

RUN git checkout ${SOFTHSM_VER} \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install

WORKDIR /pkcs11-proxy_tmp

RUN cmake . \
    && make \
    && make install


FROM ubuntu:25.04 as final

RUN useradd -m softhsm \
    && mkdir /home/softhsm/tokens \
    && chown -R softhsm:softhsm /home/softhsm/tokens

WORKDIR /home/softhsm

COPY --from=builder /lib/libpkcs11-proxy.* /lib/
COPY --from=builder /bin/pkcs11-daemon /bin/pkcs11-daemon
COPY --from=builder /usr/local/bin/softhsm2* /usr/local/bin
COPY --from=builder /usr/local/lib/softhsm /usr/local/lib/softhsm
COPY files/softhsm2.conf /etc/softhsm2.conf

ENV PKCS11_DAEMON_SOCKET="tcp://127.0.0.1:2345"

USER softhsm

ENTRYPOINT [ "pkcs11-daemon", "/usr/local/lib/softhsm/libsofthsm2.so" ]
