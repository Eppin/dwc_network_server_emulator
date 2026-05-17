FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    ca-certificates \
    perl \
    libpcre3-dev \
    zlib1g-dev \
    tar \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/src

# Build nginx 1.20.2 against OpenSSL 1.0.2k with SSLv2/SSLv3 enabled.
RUN wget https://www.openssl.org/source/old/1.0.2/openssl-1.0.2k.tar.gz \
    || wget https://github.com/openssl/openssl/releases/download/OpenSSL_1_0_2k/openssl-1.0.2k.tar.gz && \
    tar xzf openssl-1.0.2k.tar.gz && \
    wget https://nginx.org/download/nginx-1.20.2.tar.gz && \
    tar xzf nginx-1.20.2.tar.gz && \
    cd nginx-1.20.2 && \
    ./configure \
      --prefix=/opt/nginx \
      --with-http_ssl_module \
      --with-openssl=/usr/local/src/openssl-1.0.2k \
      --with-openssl-opt=enable-ssl2 \
      --with-openssl-opt=enable-ssl2-method \
      --with-openssl-opt=enable-ssl3 \
      --with-openssl-opt=enable-ssl3-method \
      --with-openssl-opt=enable-weak-ssl-ciphers && \
    make -j"$(nproc)" && \
    make install

COPY server-chain.crt /opt/nginx/conf/server-chain.crt
COPY nwc.crt /opt/nginx/conf/nwc.crt
COPY server.key /opt/nginx/conf/server.key

RUN cat > /opt/nginx/conf/nginx.conf <<'EOF'
worker_processes auto;

error_log /dev/stderr debug;
pid /tmp/nginx.pid;

events {
    worker_connections 1024;
}

http {
    access_log /dev/stdout combined;
    error_log /dev/stderr debug;
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 4096;

    include /opt/nginx/conf/mime.types;
    default_type application/octet-stream;

    underscores_in_headers on;
    proxy_pass_request_headers on;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

    # dls1 -> dwc_backend:9003
    server {
        listen 80;
        server_name dls1.nintendowifi.net;

        location / {
            proxy_pass http://dwc_backend:9003;
        }
    }

    server {
        listen 443 ssl;
        server_name dls1.nintendowifi.net;

        ssl_certificate /opt/nginx/conf/server-chain.crt;
        ssl_certificate_key /opt/nginx/conf/server.key;
        ssl_trusted_certificate /opt/nginx/conf/nwc.crt;
        ssl_protocols SSLv2 SSLv3 TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers ALL;

        location / {
            proxy_pass http://dwc_backend:9003;
        }
    }

    # gamestats -> dwc_backend:9002
    server {
        listen 80;
        server_name gamestats.gs.nintendowifi.net;

        location / {
            proxy_pass http://dwc_backend:9002;
        }
    }

    server {
        listen 443 ssl;
        server_name gamestats.gs.nintendowifi.net;

        ssl_certificate /opt/nginx/conf/server-chain.crt;
        ssl_certificate_key /opt/nginx/conf/server.key;
        ssl_trusted_certificate /opt/nginx/conf/nwc.crt;
        ssl_protocols SSLv2 SSLv3 TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers ALL;

        location / {
            proxy_pass http://dwc_backend:9002;
        }
    }

    # gamestats2 -> dwc_backend:9002
    server {
        listen 80;
        server_name gamestats2.gs.nintendowifi.net;

        location / {
            proxy_pass http://dwc_backend:9002;
        }
    }

    server {
        listen 443 ssl;
        server_name gamestats2.gs.nintendowifi.net;

        ssl_certificate /opt/nginx/conf/server-chain.crt;
        ssl_certificate_key /opt/nginx/conf/server.key;
        ssl_trusted_certificate /opt/nginx/conf/nwc.crt;
        ssl_protocols SSLv2 SSLv3 TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers ALL;

        location / {
            proxy_pass http://dwc_backend:9002;
        }
    }

    # nas/naswii/conntest -> dwc_backend:9000
    server {
        listen 80;
        server_name naswii.nintendowifi.net nas.nintendowifi.net conntest.nintendowifi.net;

        location / {
            proxy_pass http://dwc_backend:9000;
        }
    }

    server {
        listen 443 ssl;
        server_name naswii.nintendowifi.net nas.nintendowifi.net conntest.nintendowifi.net;

        ssl_certificate /opt/nginx/conf/server-chain.crt;
        ssl_certificate_key /opt/nginx/conf/server.key;
        ssl_trusted_certificate /opt/nginx/conf/nwc.crt;
        ssl_protocols SSLv2 SSLv3 TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers ALL;

        location / {
            proxy_pass http://dwc_backend:9000;
        }
    }

    # sake and secure.sake -> dwc_backend:8000
    server {
        listen 80;
        server_name sake.gs.nintendowifi.net *.sake.gs.nintendowifi.net secure.sake.gs.nintendowifi.net *.secure.sake.gs.nintendowifi.net;

        location / {
            proxy_pass http://dwc_backend:8000;
        }
    }

    server {
        listen 443 ssl;
        server_name sake.gs.nintendowifi.net *.sake.gs.nintendowifi.net secure.sake.gs.nintendowifi.net *.secure.sake.gs.nintendowifi.net;

        ssl_certificate /opt/nginx/conf/server-chain.crt;
        ssl_certificate_key /opt/nginx/conf/server.key;
        ssl_trusted_certificate /opt/nginx/conf/nwc.crt;
        ssl_protocols SSLv2 SSLv3 TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers ALL;

        location / {
            proxy_pass http://dwc_backend:8000;
        }
    }
}
EOF

EXPOSE 80 443

CMD ["/opt/nginx/sbin/nginx", "-g", "daemon off;"]
