{% from slspath ~ '/init.sls' import role, software %}

{{ software.repository(
  state_id='frrouting/repository',
  name='frrouting',
  sources=role.vars.repository_sources,
  gpg_key_url=role.vars.repository_gpg_key_url,
) }}

frrouting/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}
    - require:
      - frrouting/repository

frrouting/config:
  file.managed:
    - name: {{ role.vars.config_path|yaml_dquote }}
    - source: {{ role.tpl_path('frr.conf.j2')|yaml_dquote }}
    - check_cmd: {{ role.vars.config_check_cmd|yaml_dquote }}
    - template: 'jinja'
    - user: {{ role.vars.service_user|yaml_dquote }}
    - group: {{ role.vars.service_group|yaml_dquote }}
    - mode: '0640'
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - pkg: frrouting/packages
    - watch_in:
      - service: frrouting/service

{% for _daemon_name, _daemon_state in role.vars.daemons|dictsort %}
frrouting/daemons/{{ _daemon_name }}:
  file.line:
    - name: {{ role.vars.daemons_config_path|yaml_dquote }}
    - content: {{ (_daemon_name ~ '=' ~ ('yes' if _daemon_state else 'no'))|yaml_dquote }}
    - match: {{ ('^' ~ _daemon_name ~ '=')|yaml_dquote }}
    - mode: 'replace'
    - user: {{ role.vars.service_user|yaml_dquote }}
    - group: {{ role.vars.service_group|yaml_dquote }}
    - file_mode: '0640'
    - require:
      - pkg: frrouting/packages
    - watch_in:
      - service: frrouting/service
{% endfor %}

# See https://github.com/FRRouting/frr/issues/4249#issuecomment-504686409
frrouting/service-after-networking:
  file.managed:
    - name: '/etc/systemd/system/frr.service.d/override.conf'
    - contents: |
        [Unit]
        After=networking.service
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - dir_mode: '0755'
    - makedirs: true
    - require:
      - pkg: frrouting/packages

  module.run:
    - name: 'service.systemctl_reload'
    - onchanges:
      - file: frrouting/service-after-networking
    - require_in:
      - service: frrouting/service

frrouting/service:
  service.running:
    - name: {{ role.vars.service|yaml_dquote }}
    - enable: True
    - reload: True
    - require:
      - pkg: frrouting/packages
