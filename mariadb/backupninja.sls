{% from slspath ~ '/init.sls' import role %}
{% import 'backupninja/macros.sls' as backupninja %}

include:
  - backupninja

{% load_yaml as _job_options %}
  __global__:
    - databases: 'all'
    - backupdir: '/var/backups/mariadb'
    - hotcopy: 'no'
    - sqldump: 'yes'
    - compress: 'yes'
    - dbusername: 'root'
{% endload %}

{{ backupninja.declare_job('50-mariadb.mysql', _job_options) }}
