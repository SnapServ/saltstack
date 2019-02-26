{% from slspath ~ '/init.sls' import role %}

knot/packages:
  pkg.installed:
    - pkgs: {{ role.packages|yaml }}
    {% if 'packages_fromrepo' in role %}
    - fromrepo: {{ role.packages_fromrepo }}
    {% endif %}

knot/config:
  file.managed:
    - name: {{ role.config_path|yaml_dquote }}
    - source: {{ ('salt://' ~ slspath ~ '/files/knot.conf.j2')|yaml_dquote }}
    - check_cmd: {{ role.config_check_cmd|yaml_dquote }}
    - template: 'jinja'
    - user: {{ role.service_user|yaml_dquote }}
    - group: {{ role.service_group|yaml_dquote }}
    - mode: '0640'
    - context:
        role: {{ role|yaml }}
    - require:
      - pkg: knot/packages

knot/zonefiles-dir:
  file.directory:
    - name: {{ role.zonefiles_dir|yaml_dquote }}
    - user: {{ role.service_user|yaml_dquote }}
    - group: {{ role.service_group|yaml_dquote }}
    - group: 'root'
    - mode: '0750'
    - clean: True
    - require:
      - pkg: knot/packages
    - watch_in:
      - service: knot/service

{% set _zonefiles = salt['custom.parse_pillar_zones'](role.zonefiles) %}
{% for _zonefile_name, _zonefile in _zonefiles|dictsort %}
{% set _zonefile = salt['custom.deep_merge'](role.zonefile_defaults, _zonefile) %}

{% if not _zonefile_name.startswith('.') %}
knot/zonefiles/{{ _zonefile_name }}:
  file.managed:
    - name: {{ (role.zonefiles_dir ~ '/' ~ _zonefile_name ~ '.zone')|yaml_dquote }}
    - source: {{ ('salt://' ~ slspath ~ '/files/zonefile.zone.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: {{ role.service_user|yaml_dquote }}
    - group: {{ role.service_group|yaml_dquote }}
    - group: 'root'
    - mode: '0640'
    - dir_mode: '0750'
    - makedirs: True
    - context:
        role: {{ role|yaml }}
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
    - name: {{ role.service|yaml_dquote }}
    - enable: True
    - reload: True
    - watch:
      - file: knot/config
