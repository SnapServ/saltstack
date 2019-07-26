{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import icinga %}

icinga/packages:
  pkg.installed:
    - pkgs: {{ icinga.packages|yaml }}
    {%- if 'packages_fromrepo' in icinga %}
    - fromrepo: {{ icinga.packages_fromrepo|yaml_encode }}
    {%- endif %}

icinga/global-zone/directory:
  file.directory:
    - name: {{ icinga.global_zone_dir|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0755'
    - clean: True
    - require:
      - icinga/packages

{%- for _file_name, _file in icinga.global_zone_files|dictsort %}
icinga/global-zone/files/{{ _file_name }}:
  file.managed:
    - name: {{ (icinga.global_zone_dir ~ '/' ~ _file_name)|yaml_dquote }}
    - contents: {{ _file|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - dir_mode: '0755'
    - makedirs: True
    - require:
      - pkg: icinga/packages
    - require_in:
      - file: icinga/global-zone/directory
    - watch_in:
      - service: icinga/service
{%- endfor %}

icinga/service:
  service.running:
    - name: {{ icinga.service|yaml_dquote }}
    - enable: True
    - reload: True
    - require:
      - file: icinga/global-zone/directory
