{% set role = salt['ssx.role_data']('motd') %}

motd/packages:
  pkg.installed:
    - pkgs: {{ role.packages|yaml }}

motd/deploy-dynamic:
  file.recurse:
    - name: {{ role.dynamic_motd_dir|yaml_dquote }}
    - source: {{ ('salt://' ~ slspath ~ '/files/')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - file_mode: '0755'
    - dir_mode: '0755'
    - clean: True
    - context:
        role: {{ role|yaml }}
    - require:
      - pkg: motd/packages

motd/remove-static:
  file.absent:
    - name: {{ role.static_motd_path|yaml_dquote }}
    - require:
      - file: motd/deploy-dynamic
