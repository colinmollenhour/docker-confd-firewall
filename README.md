Docker Confd Firewall
---------------------

This "firewall" container opens ports on the host on which it is running, based on the contents of
etcd host to discover the IP addresses which should be whitelisted while supporting automatic updates via confd.


#### Environment Variables

* ETCD_URL - Url to etcd cluster containing list of machines to allow. (optional)
* FW_GRIDS - The grid names to expose ports to (`*` for all grids - optional if not using etcd).
* FW_MODE - Either 'docker' for published ports, 'kontena' for Kontena services, or 'host' for others.
* FW_SERVICE - A prefix for the firewall table rules (does not have to match anything, just has to not conflict with other instances of the firewall on the same host).
* FW_PROTO - Comma-separated list of protocols to expose (e.g. tcp or udp or tcp,udp).
* FW_PORTS - Comma-separated list of port numbers to expose (ranges allowed).
* FW_STATIC - Comma-separated list of IPs/CIDRs to always allow.
* FW_DENY - Deny behavior, e.g. DROP or REJECT (default: REJECT).
* FW_DISABLE - With the value "1" the firewall rules will be removed.
* IPTABLES_NFT - Use "1" if you are using nft on the host. Otherwise iptables-legacy will be used.


#### Etcd Data

The data is expected to be organized using the following structure:

    /mirror/v1/{grid}/{node} = {ip}

It might also work to use environment variables (not tested):

    FW_GRIDS=FOO
    MIRROR_V1_FOO_BAR={ip}
    MIRROR_V1_FOO_BAZ={ip}


#### Docker Compose Example

```yml
version: '2'
services:
  redis:
    image: redis:latest
    ports:
      - "6379:6379"
  firewall:
    image: colinmollenhour/confd-firewall
    environment:
      - FW_MODE=docker
      - FW_SERVICE=redis
      - FW_PROTO=tcp
      - FW_PORTS=6379
      - FW_STATIC=8.9.10.11/30,18.19.20.21/30
    cap_add:
      - NET_ADMIN
    network_mode: host
```



