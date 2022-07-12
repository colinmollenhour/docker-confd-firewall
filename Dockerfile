FROM debian:jessie-slim

# ca-certificates is needed if using SSL but not client certificates
RUN apt-get update \
   && DEBIAN_FRONTEND=noninteractive apt-get install -y -q --no-install-recommends \
     ca-certificates \
     iproute2 \
     iptables \
   && mkdir -p /etc/confd/conf.d

COPY bin/confd                   /usr/local/bin/
COPY docker-entrypoint.sh        /
COPY *.toml                      /etc/confd/configs/
COPY *.tmpl                      /etc/confd/templates/
COPY cloudflare.yml              /usr/share/

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["confd"]
