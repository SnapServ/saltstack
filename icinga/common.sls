{% from slspath ~ '/init.sls' import role %}

icinga/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}
    {% if 'packages_fromrepo' in role.vars %}
    - fromrepo: {{ role.vars.packages_fromrepo|yaml_encode }}
    {% endif %}

icinga/global-zone/directory:
  file.directory:
    - name: {{ role.vars.global_zone_dir|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0755'
    - clean: true
    - require:
      - icinga/packages

{% for _file_name, _file in role.vars.global_zone_files|dictsort %}
icinga/global-zone/files/{{ _file_name }}:
  file.managed:
    - name: {{ (role.vars.global_zone_dir ~ '/' ~ _file_name)|yaml_dquote }}
    - contents: {{ _file|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - dir_mode: '0755'
    - makedirs: true
    - require:
      - pkg: icinga/packages
    - require_in:
      - file: icinga/global-zone/directory
    - watch_in:
      - service: icinga/service
{% endfor %}

icinga/service:
  service.running:
    - name: {{ role.vars.service|yaml_dquote }}
    - enable: true
    - reload: true
    - require:
      - file: icinga/global-zone/directory
