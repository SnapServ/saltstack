base:
  '*':
    - locale
    - timezone
    - resolvconf
    - software
    - ntp
    - account
    - sudo
    - openssh
    - unattended-upgrades
    - motd

  'I.@backupninja.managed': [backupninja]
  'I.@incron.managed': [incron]
  'I.@jdownloader.managed': [jdownloader]
  'I.@grafana.managed': [grafana]
  'I.@nftables.managed': [nftables]
  'I.@plexmediaserver.managed': [plexmediaserver]
  'I.@prometheus.managed': [prometheus]
  'I.@samba.managed': [samba]
  'I.@syncthing.managed': [syncthing]
