{% from slspath ~ '/init.sls' import role, account %}

include:
  - .dependencies
  - .global

{# Prepare empty dictionary of service instances #}
{% set _instances = {} %}

{# Add running service instances as disabled (to delete them if unconfigured) #}
{% for _name in salt['ssx.service_unit_instances'](role.vars.service_template) %}
  {% do _instances.update(salt['ss.merge_recursive'](_instances, {
    _name: { 'enabled': false },
  })) %}
{% endfor %}

{# Merge configured service instances #}
{% for _instance_name, _instance in role.vars.instances|dictsort %}
  {% set _instance = salt['ss.merge_recursive'](role.vars.instance_defaults, _instance) %}
  {% do _instance.update({
    'username': _instance.username or _instance_name,
  }) %}
  
  {% do _instances.update(salt['ss.merge_recursive'](_instances, {
    _instance_name: _instance,
  })) %}
{% endfor %}

{# Generate states for each configured instance #}
{% for _instance_name, _instance in _instances|dictsort %}
{% if _instance.enabled %}

syncthing/instance/{{ _instance_name }}/service:
  service.running:
    - name: {{ (role.vars.service_template ~ '@' ~ _instance_name ~ '.service')|yaml_dquote }}
    - enable: True
    - require:
      - pkg: syncthing/packages
      - {{ account.resource('user', _instance.username) }}

{% else %}

syncthing/instance/{{ _instance_name }}/service:
  service.dead:
    - name: {{ (role.vars.service_template ~ '@' ~ _instance_name ~ '.service')|yaml_dquote }}
    - enable: False
    - require:
      - pkg: syncthing/packages

{% endif %}
{% endfor %}
