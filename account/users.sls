{% from slspath ~ '/init.sls' import role %}

{% for _user_name, _user in role.vars.users|dictsort %}
{% set _user = salt['ss.merge_recursive'](role.vars.user_defaults, _user) %}
{% set _user_group = _user.group or _user_name %}

{{ role.resource('user', _user_name) }}:
  ss.resource: []

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
      - {{ role.resource('user', _user_name) }}
    - require:
      - {{ role.resource('group', _user_group) }}
      {% for _group in _user.groups %}
      - {{ role.resource('group', _group) }}
      {% endfor %}
{% else %}
  user.absent:
    - name: {{ _user_name|yaml_dquote }}
    - onchanges_in:
      - {{ role.resource('user', _user_name) }}
{% endif %}

{% endfor %}
