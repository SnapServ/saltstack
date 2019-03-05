{% from slspath ~ '/init.sls' import role %}

motd/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}

motd/deploy-dynamic:
  file.recurse:
    - name: {{ role.vars.dynamic_motd_dir|yaml_dquote }}
    - source: {{ role.tpl_path()|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - file_mode: '0755'
    - dir_mode: '0755'
    - clean: True
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - pkg: motd/packages

motd/remove-static:
  file.absent:
    - name: {{ role.vars.static_motd_path|yaml_dquote }}
    - require:
      - file: motd/deploy-dynamic
