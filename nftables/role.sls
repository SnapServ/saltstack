{% set role = salt['ssx.role_data']('nftables') %}

nftables/packages:
  pkg.installed:
    - pkgs: {{ role.packages|yaml }}

nftables/ruleset:
  file.managed:
    - name: {{ role.ruleset_path }}
    - source: {{ ('salt://' ~ slspath ~ '/files/salt.ruleset.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0640'
    - context:
        role: {{ role|yaml }}
    - require:
      - pkg: nftables/packages

nftables/reload:
  cmd.run:
    - name: {{ (role.nft_bin ~ ' -f ' ~ role.ruleset_path)|yaml_dquote }}
    - onchanges:
      - file: nftables/ruleset
