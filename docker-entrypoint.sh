#!/bin/bash
#
# Colin Mollenhour

# Clear the file so that it will be run on container restart
>/usr/local/bin/iptables.sh

# Fix issues with iptables-legacy
update-alternatives --set iptables /usr/sbin/iptables-legacy || true

case "$FW_MODE" in
  docker|host)
    cp /etc/confd/configs/docker.toml /etc/confd/conf.d
  ;;
  kontena)
    cp /etc/confd/configs/kontena.toml /etc/confd/conf.d
  ;;
  *)
    echo "FW_MODE is not set."
    exit 1;
  ;;
esac
if [[ -n "$ETCD_URL" ]]; then
  ARGS="$ARGS -watch -backend etcd -node $ETCD_URL"
else
  ARGS="$ARGS -onetime -backend env"
fi
if [[ $DEBUG -eq 1 ]]; then
  ARGS="$ARGS -log-level debug"
fi

echo "Starting confd in $FW_MODE mode with args: $@ $ARGS"

# TODO - catch TERM/KILL signal and run `iptables.sh disable` before exiting

if [[ -n "$ETCD_URL" ]]; then
  exec "$@" $ARGS
else
  "$@" $ARGS
  /usr/local/bin/iptables.sh | /sbin/iptables-restore --counters
  echo "Sleeping forever..."
  sleep inf
fi
