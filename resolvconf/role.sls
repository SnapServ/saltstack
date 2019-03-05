{% from slspath ~ '/init.sls' import role %}

resolvconf/config:
  file.managed:
    - name: {{ role.vars.resolvconf_path|yaml_dquote }}
    - source: {{ role.tpl_path('resolvconf.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        vars: {{ role.vars|yaml }}
