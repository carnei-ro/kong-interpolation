#!/bin/bash
export KONG_DECLARATIVE_CONFIG=${KONG_DECLARATIVE_CONFIG:-"/etc/kong/kong.yaml"}
if [ "x${DECLARATIVES_DIR}" != "x" ]; then
  yq m -a $(find ${DECLARATIVES_DIR} -type f -iname "*.yaml" -o -iname "*.yml" | paste -s -d" ") > /tmp/merged.yaml
  envsubst < /tmp/merged.yaml > ${KONG_DECLARATIVE_CONFIG}
fi
if [ ! -f ${KONG_DECLARATIVE_CONFIG} ]; then
  kong config init
  mv kong.yml /etc/kong/kong.yaml
else 
  envsubst < ${KONG_DECLARATIVE_CONFIG} > /tmp/interpolated.yaml
  export KONG_DECLARATIVE_CONFIG=/tmp/interpolated.yaml
fi

. /docker-entrypoint.sh
