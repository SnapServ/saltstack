{% from slspath ~ '/init.sls' import role %}

knot/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}
    {% if 'packages_fromrepo' in role.vars %}
    - fromrepo: {{ role.vars.packages_fromrepo }}
    {% endif %}

knot/config:
  file.managed:
    - name: {{ role.vars.config_path|yaml_dquote }}
    - source: {{ role.tpl_path('knot.conf.j2')|yaml_dquote }}
    - check_cmd: {{ role.vars.config_check_cmd|yaml_dquote }}
    - template: 'jinja'
    - user: {{ role.vars.service_user|yaml_dquote }}
    - group: {{ role.vars.service_group|yaml_dquote }}
    - mode: '0640'
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - pkg: knot/packages

knot/zonefiles-dir:
  file.directory:
    - name: {{ role.vars.zonefiles_dir|yaml_dquote }}
    - user: {{ role.vars.service_user|yaml_dquote }}
    - group: {{ role.vars.service_group|yaml_dquote }}
    - group: 'root'
    - mode: '0750'
    - clean: True
    - require:
      - pkg: knot/packages
    - watch_in:
      - service: knot/service

{% set _zonefiles = salt['ss_knot.parse_pillar_zones'](role.vars.zonefiles) %}
{% for _zonefile_name, _zonefile in _zonefiles|dictsort %}
{% set _zonefile = salt['ss.merge_recursive'](role.vars.zonefile_defaults, _zonefile) %}

{% if not _zonefile_name.startswith('.') %}
knot/zonefiles/{{ _zonefile_name }}:
  file.managed:
    - name: {{ (role.vars.zonefiles_dir ~ '/' ~ _zonefile_name ~ '.zone')|yaml_dquote }}
    - source: {{ role.tpl_path('zonefile.zone.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: {{ role.vars.service_user|yaml_dquote }}
    - group: {{ role.vars.service_group|yaml_dquote }}
    - group: 'root'
    - mode: '0640'
    - dir_mode: '0750'
    - makedirs: True
    - context:
        vars: {{ role.vars|yaml }}
        zonefile_name: {{ _zonefile_name|yaml }}
        zonefile: {{ _zonefile|yaml }}
    - require_in:
      - file: knot/zonefiles-dir      
    - watch_in:
      - service: knot/service
{% endif %}
{% endfor %}

knot/service:
  service.running:
    - name: {{ role.vars.service|yaml_dquote }}
    - enable: True
    - reload: True
    - watch:
      - file: knot/config
