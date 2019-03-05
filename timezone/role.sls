{% from slspath ~ '/init.sls' import role %}

timezone/system:
  timezone.system:
    - name: {{ role.vars.system_timezone|yaml_dquote }}
    - utc: {{ role.vars.is_hwclock_utc|yaml_encode }}

timezone/persistence:
  file.managed:
    - name: {{ role.vars.timezone_path|yaml_dquote }}
    - contents: {{ role.vars.system_timezone|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - require:
      - timezone: timezone/system
