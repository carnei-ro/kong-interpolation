ARG VERSION=1.1.2

FROM kong:$VERSION-centos

ENV KONG_PROXY_ERROR_LOG=/dev/stderr
ENV KONG_PROXY_ACCESS_LOG=/dev/stdout
ENV KONG_ADMIN_ERROR_LOG=/dev/stderr
ENV KONG_ADMIN_ACCESS_LOG=/dev/stdout
ENV KONG_ADMIN_LISTEN=0.0.0.0:8001
ENV KONG_DATABASE=off

COPY yq /usr/local/bin/yq
COPY entrypoint.sh /

RUN yum install gettext -y ;\
  chmod +x /usr/local/bin/yq /entrypoint.sh ;\
  mkdir -p /tmp/build/usr/local/openresty/luajit/bin/ ;\
  ln -s /usr/local/openresty/luajit/bin/luajit /tmp/build/usr/local/openresty/luajit/bin/luajit ;\
  find / -maxdepth 1 -type f -iname "*rock" -exec luarocks install {} \; ;\
  rm -fr /*.rock

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGTERM

CMD ["kong", "docker-start"]
