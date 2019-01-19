{% from slspath ~ '/init.sls' import role %}

{% for _user_name, _user in role.users|dictsort %}
{% set _user = salt['custom.deep_merge'](role.user_defaults, _user) %}
{% set _user_group = _user.group or _user_name %}

$system/user/{{ _user_name }}:
  custom.resource: []

account/user/{{ _user_name }}:
{% if _user.enabled %}
  user.present:
    - name: {{ _user_name|yaml_dquote }}
    - fullname: {{ _user.fullname|yaml_dquote }}
    - password: {{ _user.password|yaml_dquote }}
    - shell: {{ _user.shell|yaml_dquote }}
    - groups: {{ _user.groups|yaml }}
    - system: {{ _user.system|yaml_encode }}
    - createhome: {{ _user.create_home|yaml_encode }}
    - remove_groups: {{ _user.remove_groups|yaml_encode }}
    - uid: {{ _user.uid|yaml_encode }}
    - gid: {{ _user_group|yaml_dquote }}
    - gid_from_name: True
    - onchanges_in:
      - custom: $system/user/{{ _user_name }}
    - require:
      - custom: $system/group/{{ _user_group }}
      {% for _group in _user.groups %}
      - custom: $system/group/{{ _group }}
      {% endfor %}
{% else %}
  user.absent:
    - name: {{ _user_name|yaml_dquote }}
    - onchanges_in:
      - custom: $system/user/{{ _user_name }}
{% endif %}

{% endfor %}
