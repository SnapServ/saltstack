{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import account %}

{%- for _user_name, _user in account.users|dictsort %}

{#- Merge user settings with default settings #}
{%- set _user = salt['defaults.merge'](
  account.user_defaults, _user, in_place=False
) %}
{%- set _user_group = _user.group or _user_name %}

{#- Declare formula resource for system user #}
{{- stdlib.formula_resource(tpldir, 'system-user', _user_name) }}

{#- Declare system user #}
account/user/{{ _user_name }}:
{%- if _user.enabled %}
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
      - {{ stdlib.resource_dep('system-user', _user_name) }}
    - require:
      - {{ stdlib.resource_dep('system-group', _user_group) }}
      {% for _group in _user.groups %}
      - {{ stdlib.resource_dep('system-group', _group) }}
      {% endfor %}
{%- else %}
  user.absent:
    - name: {{ _user_name|yaml_dquote }}
    - onchanges_in:
      - {{ stdlib.resource_dep('system-user', _user_name) }}
{%- endif %}

{%- endfor %}
