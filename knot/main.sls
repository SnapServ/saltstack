{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import knot %}

knot/packages:
  pkg.installed:
    - pkgs: {{ knot.packages|yaml }}
    {%- if 'packages_fromrepo' in knot %}
    - fromrepo: {{ knot.packages_fromrepo }}
    {%- endif %}

knot/config:
  file.managed:
    - name: {{ knot.config_path|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['knot.conf.j2'],
        lookup='knot-config'
      ) }}
    - check_cmd: {{ knot.config_check_cmd|yaml_dquote }}
    - template: 'jinja'
    - user: {{ knot.service_user|yaml_dquote }}
    - group: {{ knot.service_group|yaml_dquote }}
    - mode: '0640'
    - context:
        knot: {{ knot|yaml }}
    - require:
      - pkg: knot/packages

knot/zonefiles-dir:
  file.directory:
    - name: {{ knot.zonefiles_dir|yaml_dquote }}
    - user: {{ knot.service_user|yaml_dquote }}
    - group: {{ knot.service_group|yaml_dquote }}
    - group: 'root'
    - mode: '0750'
    - clean: True
    - require:
      - pkg: knot/packages
    - watch_in:
      - service: knot/service

{%- set _zonefiles = salt['ss_knot.parse_pillar_zones'](knot.zonefiles) %}
{%- for _zonefile_name, _zonefile in _zonefiles|dictsort %}

{#- Merge zonefile settings with defaults #}
{%- set _zonefile = salt['defaults.merge'](
  knot.zonefile_defaults,
  _zonefile,
  in_place=False
) %}

{#- Do not configure zonefiles starting with a dot - they're YAML snippets #}
{%- if not _zonefile_name.startswith('.') %}
knot/zonefiles/{{ _zonefile_name }}:
  file.managed:
    - name: {{ (knot.zonefiles_dir ~ '/' ~ _zonefile_name ~ '.zone')|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['zonefile.zone.j2'],
        lookup='zonefile-config'
      ) }}
    - template: 'jinja'
    - user: {{ knot.service_user|yaml_dquote }}
    - group: {{ knot.service_group|yaml_dquote }}
    - group: 'root'
    - mode: '0640'
    - dir_mode: '0750'
    - makedirs: True
    - context:
        knot: {{ knot|yaml }}
        zonefile_name: {{ _zonefile_name|yaml }}
        zonefile: {{ _zonefile|yaml }}
    - require_in:
      - file: knot/zonefiles-dir      
    - watch_in:
      - service: knot/service
{%- endif %}

{%- endfor %}

knot/service:
  service.running:
    - name: {{ knot.service|yaml_dquote }}
    - enable: True
    - reload: True
    - watch:
      - file: knot/config
