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

frrouting/service:
  service.running:
    - name: {{ role.vars.service|yaml_dquote }}
    - enable: True
    - reload: True
    - require:
      - pkg: frrouting/packages
