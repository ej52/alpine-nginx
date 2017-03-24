FROM ej52/alpine-base:latest
MAINTAINER Elton Renda "https://github.com/ej52"

ENV NGINX_VERSION=1.11.10

RUN \
  # Install build and runtime packages
  build_pkgs="build-base linux-headers openssl-dev pcre-dev wget zlib-dev" \ 
  && runtime_pkgs="ca-certificates openssl pcre zlib" \
  && apk --no-cache add ${build_pkgs} ${runtime_pkgs} \
  
   # download unpack nginx-src
  && mkdir /tmp/nginx && cd /tmp/nginx \
  && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
  && tar xzf nginx-${NGINX_VERSION}.tar.gz \
  && cd nginx-${NGINX_VERSION} \
  
  #compile
  && ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=www-data \
    --group=www-data \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-stream_realip_module \
    --with-http_slice_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-compat \
    --with-file-aio \
    --with-http_v2_module \
  && make \
  && make install \
  && make clean \
  
  # strip debug symbols from the binary (GREATLY reduces binary size)
  && strip -s /usr/sbin/nginx \
  
  # add www-data user and create cache dir
  && adduser -D www-data \
  && mkdir /var/cache/nginx \
  
  # remove NGINX dev dependencies
  && apk del ${build_pkgs} \
  
  # other clean up
  && cd / \
  && rm /etc/nginx/*.default \
  && rm -rf /var/cache/apk/* \
  && rm -rf /tmp/* \
  && rm -rf /var/www/*

COPY root /

VOLUME ["/var/cache/nginx"]

EXPOSE 80 443
