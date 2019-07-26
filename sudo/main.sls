{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import sudo %}

sudo/packages:
  pkg.installed:
    - pkgs: {{ sudo.packages|yaml }}

sudo/config:
  file.managed:
    - name: {{ sudo.sudoers_path|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['sudoers.j2'],
        lookup='sudoers-config'
      ) }}
    - check_cmd: {{ sudo.sudoers_check_cmd|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0640'
    - context:
        sudo: {{ sudo|yaml }}
    - require:
      - pkg: sudo/packages
