{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import timezone %}

timezone/system:
  timezone.system:
    - name: {{ timezone.system_timezone|yaml_dquote }}
    - utc: {{ timezone.is_hwclock_utc|yaml_encode }}

timezone/persistence:
  file.managed:
    - name: {{ timezone.timezone_path|yaml_dquote }}
    - contents: {{ timezone.system_timezone|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - require:
      - timezone: timezone/system
