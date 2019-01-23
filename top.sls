base:
  '*':
    - locale
    - timezone
    - resolvconf
    - hosts
    - interfaces
    - software
    - ntp
    - account
    - sudo
    - openssh
    - unattended-upgrades
    - motd

  'I.@acme-dns.managed': [acme-dns]
  'I.@backupninja.managed': [backupninja]
  'I.@docker.managed': [docker]
  'I.@grafana.managed': [grafana]
  'I.@incron.managed': [incron]
  'I.@jdownloader.managed': [jdownloader]
  'I.@mariadb.managed': [mariadb]
  'I.@nftables.managed': [nftables]
  'I.@nginx.managed': [nginx]
  'I.@php-fpm.managed': [php-fpm]
  'I.@plexmediaserver.managed': [plexmediaserver]
  'I.@prometheus.managed': [prometheus]
  'I.@prosody.managed': [prosody]
  'I.@samba.managed': [samba]
  'I.@syncthing.managed': [syncthing]
