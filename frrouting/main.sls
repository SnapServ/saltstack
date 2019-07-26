{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import frrouting %}
{%- from stdlib.formula_macros('software') import software_repository %}

include:
  - software

{{ software_repository(
  name='frrouting',
  sources=frrouting.repository_sources,
  gpg_key_url=frrouting.repository_gpg_key_url,
) }}

frrouting/packages:
  pkg.installed:
    - pkgs: {{ frrouting.packages|yaml }}
    - require:
      - {{ stdlib.resource_dep('software-repository', 'frrouting') }}

frrouting/config:
  file.managed:
    - name: {{ frrouting.config_path|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['frr.conf.j2'],
        lookup='frrouting-config'
      ) }}
    - check_cmd: {{ frrouting.config_check_cmd|yaml_dquote }}
    - template: 'jinja'
    - user: {{ frrouting.service_user|yaml_dquote }}
    - group: {{ frrouting.service_group|yaml_dquote }}
    - mode: '0640'
    - context:
        frrouting: {{ frrouting|yaml }}
    - require:
      - pkg: frrouting/packages
    - watch_in:
      - service: frrouting/service

{%- for _daemon_name, _daemon_state in frrouting.daemons|dictsort %}
frrouting/daemons/{{ _daemon_name }}:
  file.line:
    - name: {{ frrouting.daemons_config_path|yaml_dquote }}
    - content: {{ (_daemon_name ~ '=' ~ ('yes' if _daemon_state else 'no'))|yaml_dquote }}
    - match: {{ ('^' ~ _daemon_name ~ '=')|yaml_dquote }}
    - mode: 'replace'
    - user: {{ frrouting.service_user|yaml_dquote }}
    - group: {{ frrouting.service_group|yaml_dquote }}
    - file_mode: '0640'
    - require:
      - pkg: frrouting/packages
    - watch_in:
      - service: frrouting/service
{%- endfor %}

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
    - name: {{ frrouting.service|yaml_dquote }}
    - enable: True
    - reload: True
    - require:
      - pkg: frrouting/packages
