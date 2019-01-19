{% from slspath ~ '/init.sls' import role %}

timezone/system:
  timezone.system:
    - name: {{ role.system_timezone|yaml_dquote }}
    - utc: {{ role.is_hwclock_utc|yaml_encode }}

timezone/persistence:
  file.managed:
    - name: {{ role.timezone_path|yaml_dquote }}
    - contents: {{ role.system_timezone|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - require:
      - timezone: timezone/system
