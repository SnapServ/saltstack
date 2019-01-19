{% from slspath ~ '/init.sls' import role %}

include:
  - .dependencies
  - .global

{# Prepare empty dictionary of service instances #}
{% set _instances = {} %}

{# Add running service instances as disabled (to delete them if unconfigured) #}
{% for _name in salt['ssx.service_unit_instances'](role.service_template) %}
  {% do _instances.update(salt['custom.deep_merge'](_instances, {
    _name: { 'enabled': false },
  })) %}
{% endfor %}

{# Merge configured service instances #}
{% for _instance_name, _instance in role.instances|dictsort %}
  {% set _instance = salt['custom.deep_merge'](role.instance_defaults, _instance) %}
  {% do _instance.update({
    'username': _instance.username or _instance_name,
  }) %}
  
  {% do _instances.update(salt['custom.deep_merge'](_instances, {
    _instance_name: _instance,
  })) %}
{% endfor %}

{# Generate states for each configured instance #}
{% for _instance_name, _instance in _instances|dictsort %}
{% if _instance.enabled %}

syncthing/instance/{{ _instance_name }}/service:
  service.running:
    - name: {{ (role.service_template ~ '@' ~ _instance_name ~ '.service')|yaml_dquote }}
    - enable: True
    - require:
      - pkg: syncthing/packages
      - custom: $system/user/{{ _instance.username }}

{% else %}

syncthing/instance/{{ _instance_name }}/service:
  service.dead:
    - name: {{ (role.service_template ~ '@' ~ _instance_name ~ '.service')|yaml_dquote }}
    - enable: False
    - require:
      - pkg: syncthing/packages

{% endif %}
{% endfor %}
