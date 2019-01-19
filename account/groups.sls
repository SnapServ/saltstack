{% from slspath ~ '/init.sls' import role %}

{# Create dynamic groups for users without an explicit default/primary group #}
{% set _groups = role.groups %}
{% for _user_name, _user in role.users|dictsort %}
  {% set _user = salt['custom.deep_merge'](role.user_defaults, _user) %}

  {% if not _user.group and _user_name not in _groups %}
    {% do _groups.update({_user_name: {
      'system': _user.system
    }}) %}
  {% endif %}
{% endfor %}

{% for _group_name, _group in role.groups|dictsort %}
{% set _group = salt['custom.deep_merge'](role.group_defaults, _group) %}

$system/group/{{ _group_name }}:
  custom.resource: []

account/group/{{ _group_name }}:
{% if _group.enabled %}
  group.present:
    - name: {{ _group_name }}
    - gid: {{ _group.gid|yaml_encode }}
    - system: {{ _group.system|yaml_encode }}
    - onchanges_in:
      - custom: $system/group/{{ _group_name }}
{% else %}
  group.absent:
    - name: {{ _group_name }}
    - onchanges_in:
      - custom: $system/group/{{ _group_name }}
{% endif %}

{% endfor %}
