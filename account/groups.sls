{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import account %}

{#- Create implicit groups for users without a primary group #}
{%- set _groups = account.groups %}
{%- for _user_name, _user in account.users|dictsort %}
  {%- set _user = salt['defaults.merge'](
    account.user_defaults, _user, in_place=False
  ) %}

  {%- if not _user.group and _user_name not in _groups %}
    {%- do _groups.update({_user_name: {
      'system': _user.system
    }}) %}
  {%- endif %}
{%- endfor %}


{%- for _group_name, _group in account.groups|dictsort %}

{#- Merge group settings with default settings #}
{%- set _group = salt['defaults.merge'](
  account.group_defaults, _group, in_place=False
) %}

{#- Declare formula resource for system group #}
{{- stdlib.formula_resource(tpldir, 'system-group', _group_name) }}

{#- Declare system group #}
account/group/{{ _group_name }}:
{%- if _group.enabled %}
  group.present:
    - name: {{ _group_name }}
    - gid: {{ _group.gid|yaml_encode }}
    - system: {{ _group.system|yaml_encode }}
    - onchanges_in:
      - {{ stdlib.resource_dep('system-group', _group_name) }}
{%- else %}
  group.absent:
    - name: {{ _group_name }}
    - onchanges_in:
      - {{ stdlib.resource_dep('system-group', _group_name) }}
{%- endif %}

{%- endfor %}
