{% from slspath ~ '/init.sls' import role %}

nginx/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}

nginx/config:
  file.managed:
    - name: {{ role.vars.config_path|yaml_dquote }}
    - source: {{ role.tpl_path('nginx.conf.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - pkg: nginx/packages
    - watch_in:
      - service: nginx/service-reload

nginx/fastcgi-config:
  file.managed:
    - name: {{ role.vars.fastcgi_config_path|yaml_dquote }}
    - source: {{ role.tpl_path('fastcgi.conf.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - pkg: nginx/packages
    - watch_in:
      - service: nginx/service-reload

nginx/service:
  service.running:
    - name: {{ role.vars.service|yaml_dquote }}
    - enable: True
    - require:
      - pkg: nginx/packages

nginx/service-reload:
  service.running:
    - name: {{ role.vars.service|yaml_dquote }}
    - reload: True
    - require:
      - service: nginx/service
