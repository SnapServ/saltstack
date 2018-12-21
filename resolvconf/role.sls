{% set role = salt['ssx.role_data']('resolvconf') %}

resolvconf/config:
  file.managed:
    - name: {{ role.resolvconf_path|yaml_dquote }}
    - source: {{ ('salt://' ~ slspath ~ '/files/resolvconf.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        role: {{ role|yaml }}
