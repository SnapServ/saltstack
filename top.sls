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

  'I.@jdownloader.managed': [jdownloader]
  'I.@plexmediaserver.managed': [plexmediaserver]
  'I.@samba.managed': [samba]
  'I.@syncthing.managed': [syncthing]
