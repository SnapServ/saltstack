{% from 'nginx/init.sls' import role %}

{% macro declare_vhost(_vhost_name, _vhost) %}
{% set _vhost = salt['custom.deep_merge'](role.vhost_defaults, _vhost) %}
{% set _vhost_state = 'nginx/vhost/' ~ _vhost_name %}
{% set _vhost_dir = role.vhost_data_dir ~ '/' ~ _vhost_name %}

{{ _vhost_state }}/filesystem/vhost:
  file.directory:
    - name: {{ _vhost_dir|yaml_dquote }}
    - user: 'root'
    - group: 'www-data'
    - mode: '0750'
    - makedirs: True
    - require:
      - pkg: nginx/packages

{{ _vhost_state }}/filesystem/app:
  file.directory:
    - name: {{ (_vhost_dir ~ '/app')|yaml_dquote }}
    - user: {{ (_vhost.app_user or role.service_user)|yaml_dquote }}
    - group: {{ (_vhost.app_group or role.service_group)|yaml_dquote }}
    - mode: '2770'
    - require:
      - file: {{ _vhost_state }}/filesystem/vhost

{{ _vhost_state }}/filesystem/app/public:
  file.directory:
    - name: {{ (_vhost_dir ~ '/app/public')|yaml_dquote }}
    - user: {{ (_vhost.app_user or role.service_user)|yaml_dquote }}
    - group: {{ (_vhost.app_group or role.service_group)|yaml_dquote }}
    - mode: '2770'
    - require:
      - file: {{ _vhost_state }}/filesystem/app

{{ _vhost_state }}/filesystem/cfg:
  file.directory:
    - name: {{ (_vhost_dir ~ '/cfg')|yaml_dquote }}
    - user: 'root'
    - group: 'www-data'
    - mode: '0770'
    - require:
      - file: {{ _vhost_state }}/filesystem/vhost

{{ _vhost_state }}/filesystem/log:
  file.directory:
    - name: {{ (_vhost_dir ~ '/log')|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0750'
    - require:
      - file: {{ _vhost_state }}/filesystem/vhost 

{{ _vhost_state }}/filesystem/tmp:
  file.directory:
    - name: {{ (_vhost_dir ~ '/tmp')|yaml_dquote }}
    - user: {{ (_vhost.app_user or role.service_user)|yaml_dquote }}
    - group: 'root'
    - mode: '1770'
    - require:
      - file: {{ _vhost_state }}/filesystem/vhost

{{ _vhost_state }}/config:
  file.managed:
    - name: {{ (role.vhosts_dir ~ '/' ~ _vhost_name ~ '.conf')|yaml_dquote }}
    - source: 'salt://nginx/files/vhost.conf.j2'
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - dir_mode: '0755'
    - makedirs: True
    - context:
        role: {{ role|yaml }}
        vhost_name: {{ _vhost_name|yaml }}
        vhost_config: {{ _vhost|yaml }}
        vhost_dir: {{ _vhost_dir|yaml }}
    - require:
      - file: {{ _vhost_state }}/filesystem/app/public
      - file: {{ _vhost_state }}/filesystem/cfg
      - file: {{ _vhost_state }}/filesystem/log
      - file: {{ _vhost_state }}/filesystem/tmp
    - require_in:
      - file: nginx/vhosts-dir
    - watch_in:
      - service: nginx/service-reload
{% endmacro %}
