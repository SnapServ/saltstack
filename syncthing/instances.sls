{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import syncthing %}

include:
  - account
  - .global

{# Prepare empty dictionary of service instances #}
{%- set _instances = {} %}

{# Add running service instances as disabled (to delete them if unconfigured) #}
{%- for _name in salt['ss.systemd_service_instances'](syncthing.service_template) %}
  {%- do _instances.update(salt['defaults.merge'](_instances, {
    _name: { 'enabled': False },
  }, in_place=False)) %}
{%- endfor %}

{# Merge configured service instances #}
{%- for _instance_name, _instance in syncthing.instances|dictsort %}
  {%- set _instance = salt['defaults.merge'](
    syncthing.instance_defaults, _instance, in_place=False
  ) %}

  {%- do _instance.update({
    'username': _instance.username or _instance_name,
  }) %}
  
  {%- do _instances.update(salt['defaults.merge'](_instances, {
    _instance_name: _instance,
  }, in_place=False)) %}
{%- endfor %}

{# Generate states for each configured instance #}
{%- for _instance_name, _instance in _instances|dictsort %}
{%- if _instance.enabled %}

syncthing/instance/{{ _instance_name }}/service:
  service.running:
    - name: {{ (syncthing.service_template ~ '@' ~ _instance_name ~ '.service')|yaml_dquote }}
    - enable: True
    - require:
      - pkg: syncthing/packages
      - {{ stdlib.resource_dep('system-user', _instance.username) }}

{%- else %}

syncthing/instance/{{ _instance_name }}/service:
  service.dead:
    - name: {{ (syncthing.service_template ~ '@' ~ _instance_name ~ '.service')|yaml_dquote }}
    - enable: False
    - require:
      - pkg: syncthing/packages

{%- endif %}
{%- endfor %}
