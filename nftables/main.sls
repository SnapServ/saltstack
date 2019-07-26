{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import nftables %}

nftables/packages:
  pkg.installed:
    - pkgs: {{ nftables.packages|yaml }}

nftables/ruleset:
  file.managed:
    - name: {{ nftables.ruleset_path|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['salt.ruleset.j2'],
        lookup='ruleset-config'
      ) }}
    - check_cmd: {{ nftables.ruleset_check_cmd|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0640'
    - context:
        nftables: {{ nftables|yaml }}
    - require:
      - pkg: nftables/packages

nftables/service:
  service.running:
    - name: {{ nftables.service|yaml_dquote }}
    - enable: True
    - watch:
      - file: nftables/ruleset
