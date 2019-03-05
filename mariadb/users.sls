{% from slspath ~ '/init.sls' import role %}

{% macro parse_grant_target(_grant) -%}
  {%- if _grant.get('database', None) -%}
    {%- if _grant.get('table', None) -%}
      {{- _grant.database ~ '.' ~ _grant.table -}}
    {%- else -%}
      {{- _grant.database ~ '.*' -}}
    {%- endif -%}
  {%- else -%}
    {{- '*.*' -}}
  {%- endif -%}
{%- endmacro %}

include:
  - .server

{% for _user_name, _user in role.vars.users|dictsort %}
{% set _user = salt['ss.merge_recursive'](role.vars.user_defaults, _user) %}
{% for _user_host in _user.hosts %}

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

{% for _user_grant in _user.grants %}
{% set _user_grant = salt['ss.merge_recursive'](role.vars.user_grant_defaults, _user_grant) %}
{% set _grant_target = parse_grant_target(_user_grant) %}
{% set _grant_privileges = _user_grant.privileges|map('upper')|join(',') %}

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
{% endfor %}

{% endfor %}
{% endfor %}
