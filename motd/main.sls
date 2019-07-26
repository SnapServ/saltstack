{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import motd %}

motd/packages:
  pkg.installed:
    - pkgs: {{ motd.packages|yaml }}

motd/deploy-dynamic:
  file.recurse:
    - name: {{ motd.dynamic_motd_dir|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['scripts/'],
        lookup='scripts-dir'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - file_mode: '0755'
    - dir_mode: '0755'
    - clean: True
    - context:
        motd: {{ motd|yaml }}
    - require:
      - pkg: motd/packages

motd/remove-static:
  file.absent:
    - name: {{ motd.static_motd_path|yaml_dquote }}
    - require:
      - file: motd/deploy-dynamic
