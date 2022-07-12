Docker Confd Firewall
---------------------

This "firewall" container uses iptables to block external access to your services except for the IPs which you wish
to allow. It can use static entries defined in an environment variable, an etcd server to update instantly when etcd
is updated, and an auto-updated list of Cloudflare IPs.

#### Environment Variables

** General **

* FW_MODE - Either 'docker' for published ports, 'kontena' for Kontena services, or 'host' for others.
* FW_SERVICE - A prefix for the firewall table rules (does not have to match anything, just has to not conflict with other instances of the firewall on the same host).
* FW_PROTO - Comma-separated list of protocols to expose (e.g. tcp or udp or tcp,udp).
* FW_PORTS - Comma-separated list of port numbers to expose (ranges allowed).
* FW_DENY - Deny behavior, e.g. DROP or REJECT (default: REJECT).
* FW_DISABLE - With the value "1" the firewall rules will be removed.

** Static entries **

* FW_STATIC - Comma-separated list of IPs/CIDRs to always allow.

** Cloudflare **

* CLOUDFLARE - Specify "1" to enable access to published Cloudflare IP list (see https://www.cloudflare.com/ips/)

** Etcd (optional) **

* ETCD_URL - Url to etcd cluster containing list of machines to allow.
* FW_GRIDS - The grid names to expose ports to (`*` for all grids).

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



