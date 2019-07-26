{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import mariadb %}

{%- macro build_grant_target(_grant) %}
  {%- if _grant.get('database', None) %}
    {%- if _grant.get('table', None) %}
      {{- _grant.database ~ '.' ~ _grant.table }}
    {%- else %}
      {{- _grant.database ~ '.*' }}
    {%- endif %}
  {%- else %}
    {{- '*.*' }}
  {%- endif %}
{%- endmacro %}

include:
  - .server

{%- for _user_name, _user in mariadb.users|dictsort %}

{#- Merge user settings with defaults #}
{%- set _user = salt['defaults.merge'](
  mariadb.user_defaults, _user, in_place=False
) %}

{#- Declare user for each specified host #}
{%- for _user_host in _user.hosts %}

mariadb/user/{{ _user_name }}-{{ _user_host }}/account:
  mysql_user.present:
    - name: {{ _user_name|yaml_dquote }}
    - host: {{ _user_host|yaml_dquote }}
    {% if _user.password_hash %}
    - password_hash: {{ _user.password_hash|yaml_dquote }}
    {% elif _user.password %}
    - password: {{ _user.password|yaml_dquote }}
    {% else %}
    - allow_passwordless: True
    {% endif %}
    - connection_host: 'localhost'
    - connection_user: 'root'
    - connection_charset: 'utf8'
    - require:
      - service: mariadb/server/service

{%- for _user_grant in _user.grants %}

{#- Merge user grant settings with defaults #}
{%- set _user_grant = salt['defaults.merge'](
  mariadb.user_grant_defaults, _user_grant, in_place=False
) %}

{#- Build user grant targets from pillar #}
{%- set _grant_target = build_grant_target(_user_grant) %}
{%- set _grant_privileges = _user_grant.privileges|map('upper')|join(',') %}

{#- Declare user grant target #}
mariadb/user/{{ _user_name }}-{{ _user_host }}/grants/{{ loop.index }}:
  mysql_grants.present:
    - user: {{ _user_name|yaml_dquote }}
    - host: {{ _user_host|yaml_dquote }}
    - database: {{ _grant_target|yaml_dquote }}
    - grant: {{ _grant_privileges|yaml_dquote }}
    - grant_option: {{ _user_grant.grant_option|yaml_encode }}
    - escape: {{ _user_grant.escape|yaml_encode }}
    - connection_host: 'localhost'
    - connection_user: 'root'
    - connection_charset: 'utf8'
    - require:
      - mysql_user: mariadb/user/{{ _user_name }}-{{ _user_host }}/account
{%- endfor %}

{%- endfor %}
{%- endfor %}
