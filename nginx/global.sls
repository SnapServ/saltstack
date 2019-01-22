{% from slspath ~ '/init.sls' import role %}

nginx/packages:
  pkg.installed:
    - pkgs: {{ role.packages|yaml }}

nginx/config:
  file.managed:
    - name: {{ role.config_path|yaml_dquote }}
    - source: {{ ('salt://' ~ slspath ~ '/files/nginx.conf.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        role: {{ role|yaml }}
    - require:
      - pkg: nginx/packages
    - watch_in:
      - service: nginx/service-reload

nginx/service:
  service.running:
    - name: {{ role.service|yaml_dquote }}
    - enable: True
    - require:
      - pkg: nginx/packages

nginx/service-reload:
  service.running:
    - name: {{ role.service|yaml_dquote }}
    - reload: True
    - require:
      - service: nginx/service
