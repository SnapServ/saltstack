{% from slspath ~ '/init.sls' import role %}

{# Create dynamic groups for users without an explicit default/primary group #}
{% set _groups = role.vars.groups %}
{% for _user_name, _user in role.vars.users|dictsort %}
  {% set _user = salt['ss.merge_recursive'](role.vars.user_defaults, _user) %}

  {% if not _user.group and _user_name not in _groups %}
    {% do _groups.update({_user_name: {
      'system': _user.system
    }}) %}
  {% endif %}
{% endfor %}

{% for _group_name, _group in role.vars.groups|dictsort %}
{% set _group = salt['ss.merge_recursive'](role.vars.group_defaults, _group) %}

{{ role.resource('group', _group_name) }}:
  ss.resource: []

account/group/{{ _group_name }}:
{% if _group.enabled %}
  group.present:
    - name: {{ _group_name }}
    - gid: {{ _group.gid|yaml_encode }}
    - system: {{ _group.system|yaml_encode }}
    - onchanges_in:
      - {{ role.resource('group', _group_name) }}
{% else %}
  group.absent:
    - name: {{ _group_name }}
    - onchanges_in:
      - {{ role.resource('group', _group_name) }}
{% endif %}

{% endfor %}
