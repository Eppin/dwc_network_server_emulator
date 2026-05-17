FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    ca-certificates \
    perl \
    libapr1-dev \
    libaprutil1-dev \
    libpcre3-dev \
    zlib1g-dev \
    tar \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/src

# OpenSSL 1.0.2u with SSLv2/SSLv3 support.
RUN wget https://github.com/openssl/openssl/releases/download/OpenSSL_1_0_2u/openssl-1.0.2u.tar.gz \
    || wget https://www.openssl.org/source/old/1.0.2/openssl-1.0.2u.tar.gz && \
    tar xzf openssl-1.0.2u.tar.gz && \
    cd openssl-1.0.2u && \
    ./config --prefix=/opt/openssl-1.0.2u shared enable-ssl3 enable-ssl3-method enable-weak-ssl-ciphers && \
    make -j"$(nproc)" && \
    make install

# Apache HTTPD linked against legacy OpenSSL.
RUN wget https://archive.apache.org/dist/httpd/httpd-2.4.59.tar.gz \
    || wget https://downloads.apache.org/httpd/httpd-2.4.59.tar.gz && \
    tar xzf httpd-2.4.59.tar.gz && \
    cd httpd-2.4.59 && \
    ./configure \
      --prefix=/opt/httpd \
      --enable-so \
      --enable-ssl \
      --enable-rewrite \
      --enable-proxy \
      --enable-proxy-http \
      --with-ssl=/opt/openssl-1.0.2u && \
    make -j"$(nproc)" && \
    make install

ENV LD_LIBRARY_PATH=/opt/openssl-1.0.2u/lib

# Change this if you have your own domain name set up
# Otherwise, you will need to set up a DNS server to point nintendowifi.net to your IP address
ENV DWC_HOST=nintendowifi.net

COPY httpd.conf /opt/httpd/conf/httpd.conf
COPY ./apache-hosts/ /opt/httpd/conf/extra/vhosts/
COPY nwc.crt /opt/httpd/conf/nwc.crt
COPY server.crt /opt/httpd/conf/server.crt
COPY server.key /opt/httpd/conf/server.key

EXPOSE 80 443

CMD ["/opt/httpd/bin/httpd", "-D", "FOREGROUND"]
