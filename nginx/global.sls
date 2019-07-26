{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import nginx %}

nginx/packages:
  pkg.installed:
    - pkgs: {{ nginx.packages|yaml }}

nginx/config:
  file.managed:
    - name: {{ nginx.config_path|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['nginx.conf.j2'],
        lookup='nginx-config'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        nginx: {{ nginx|yaml }}
    - require:
      - pkg: nginx/packages
    - watch_in:
      - service: nginx/service-reload

nginx/fastcgi-config:
  file.managed:
    - name: {{ nginx.fastcgi_config_path|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['fastcgi.conf.j2'],
        lookup='fastcgi-config'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        nginx: {{ nginx|yaml }}
    - require:
      - pkg: nginx/packages
    - watch_in:
      - service: nginx/service-reload

nginx/service:
  service.running:
    - name: {{ nginx.service|yaml_dquote }}
    - enable: True
    - require:
      - pkg: nginx/packages

nginx/service-reload:
  service.running:
    - name: {{ nginx.service|yaml_dquote }}
    - reload: True
    - require:
      - service: nginx/service
