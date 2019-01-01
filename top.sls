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

  'I.@incron.managed': [incron]
  'I.@jdownloader.managed': [jdownloader]
  'I.@nftables.managed': [nftables]
  'I.@plexmediaserver.managed': [plexmediaserver]
  'I.@samba.managed': [samba]
  'I.@syncthing.managed': [syncthing]
