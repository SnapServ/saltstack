{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import tor %}

tor/packages:
  pkg.installed:
    - pkgs: {{ tor.packages|yaml }}

tor/config:
  file.managed:
    - name: {{ tor.config_path|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['torrc.j2'],
        lookup='tor-config'
      ) }}
    - template: 'jinja'
    - user: {{ tor.service_user|yaml_dquote }}
    - group: {{ tor.service_group|yaml_dquote }}
    - mode: '0640'
    - context:
        tor: {{ tor|yaml }}
    - require:
      - pkg: tor/packages

tor/service:
  service.running:
    - name: {{ tor.service|yaml_dquote }}
    - enable: true
    - reload: true
    - watch:
      - file: tor/config
