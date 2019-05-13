base:
  '*':
    - locale
    - timezone
    - resolvconf
    - hosts
    - interfaces
    - software
    - account
    - ssl-cert
    - sudo
    - openssh
    - unattended-upgrades
    - motd

  'P@virtual:(physical|qemu)':
    - ntp

  'I.@acme-dns.managed': [acme-dns]
  'I.@backupninja.managed': [backupninja]
  'I.@borgbackup.managed': [borgbackup]
  'I.@docker.managed': [docker]
  'I.@grafana.managed': [grafana]
  'I.@icinga.managed': [icinga]
  'I.@incron.managed': [incron]
  'I.@influxdb.managed': [influxdb]
  'I.@jdownloader.managed': [jdownloader]
  'I.@knot.managed': [knot]
  'I.@mariadb.managed': [mariadb]
  'I.@nftables.managed': [nftables]
  'I.@nginx.managed': [nginx]
  'I.@oauth2-proxy.managed': [oauth2-proxy]
  'I.@php-fpm.managed': [php-fpm]
  'I.@plexmediaserver.managed': [plexmediaserver]
  'I.@prometheus.managed': [prometheus]
  'I.@prosody.managed': [prosody]
  'I.@quassel.managed': [quassel]
  'I.@samba.managed': [samba]
  'I.@syncthing.managed': [syncthing]
  'I.@telegraf.managed': [telegraf]
  'I.@tor-relay.managed': [tor-relay]
