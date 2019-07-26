{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import lldpd %}

lldpd/packages:
  pkg.installed:
    - pkgs: {{ lldpd.packages|yaml }}

lldpd/daemon-config:
  file.managed:
    - name: {{ lldpd.daemon_config_path }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['daemon-config.j2'],
        lookup='daemon-config'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        lldpd: {{ lldpd|yaml }}
    - require:
      - pkg: lldpd/packages

lldpd/service:
  service.running:
    - name: {{ lldpd.service|yaml_dquote }}
    - enable: True
    - watch:
      - file: lldpd/daemon-config
