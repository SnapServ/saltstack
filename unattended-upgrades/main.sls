{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import unattended_upgrades %}

unattended-upgrades/packages:
  pkg.installed:
    - pkgs: {{ unattended_upgrades.packages|yaml }}

unattended-upgrades/config:
  file.managed:
    - name: {{ unattended_upgrades.config_path|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['unattended-upgrades.j2'],
        lookup='unattended-upgrades-config'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        unattended_upgrades: {{ unattended_upgrades|yaml }}
    - require:
      - pkg: unattended-upgrades/packages

unattended-upgrades/service:
  service.running:
    - name: {{ unattended_upgrades.service|yaml_dquote }}
    - enable: True
    - watch:
      - file: unattended-upgrades/config
