{% from slspath ~ '/../init.sls' import role %}

include:
  - frrouting

frrouting/prefix-lists/generate:
  file.managed:
    - name: {{ role.vars.prefix_lists_path|yaml_dquote }}
    - source: {{ role.tpl_path('prefix-lists.j2')|yaml_dquote }}
    - check_cmd: >-
        {{ role.vars.vtysh_bin|quote }} -C -f
    - template: 'jinja'
    - user: {{ role.vars.service_user|yaml_dquote }}
    - group: {{ role.vars.service_group|yaml_dquote }}
    - mode: '0640'
    - dir_mode: '0750'
    - makedirs: true
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - pkg: frrouting/packages

{% set _dirty_flag_path = (role.vars.prefix_lists_path ~ '.dirty') %}

frrouting/prefix-lists/mark-dirty:
  file.managed:
    - name: {{ _dirty_flag_path|yaml_dquote }}
    - replace: false
    - onchanges:
      - file: frrouting/prefix-lists/generate

frrouting/prefix-lists/apply:
  cmd.run:
    - name: >-
        {{ role.vars.vtysh_bin|quote }} -f {{ role.vars.prefix_lists_path|quote }}
        || {{ role.vars.vtysh_bin|quote }} -f {{ role.vars.prefix_lists_path|quote }}
    - shell: '/bin/sh'
    - runas: {{ role.vars.service_user|yaml_dquote }}
    - onlyif: {{ 'test -f ' ~ (_dirty_flag_path|quote) }}

frrouting/prefix-lists/mark-clean:
  file.absent:
    - name: {{ (role.vars.prefix_lists_path ~ '.dirty')|yaml_dquote }}
    - onchanges:
      - cmd: frrouting/prefix-lists/apply
