ARG REGISTRY
FROM ${REGISTRY}/joseluisq/static-web-server:2-alpine
LABEL maintainer="dev_lau11@a.jlv6.com"
ARG JLV6_UID
ARG JLV6_USER
ARG JLV6_GID
ARG JLV6_GROUP
ENV SERVER_ROOT=/public
ENV SERVER_CONFIG_FILE=/etc/config.toml
COPY ./public /public
RUN <<EOF
  addgroup -g ${JLV6_GROUP} ${JLV6_GROUP}
  adduser -h /home/${JLV6_USER} -u ${JLV6_USER} -D -G ${JLV6_GROUP} ${JLV6_USER}
  # changing ownership of static-web-server files
  RUN chown -R ${JLV6_USER}:${JLV6_GROUP} /entrypoint.sh
  RUN chown -R ${JLV6_USER}:${JLV6_GROUP} /usr/local/bin/static-web-server
  RUN chown -R ${JLV6_USER}:${JLV6_GROUP} /public
  RUN chmod -R 770 /entrypoint.sh /usr/local/bin/static-web-server /public
EOF
USER ${JLV6_USER}
