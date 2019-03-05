{% from slspath ~ '/init.sls' import role %}
{% from slspath ~ '/users.sls' import parse_grant_target %}

include:
  - .databases
  - .users

{% set _stale_dbs = salt['mysql.db_list']() %}
{% set _stale_dbs = salt['ss.list_diff'](_stale_dbs, role.vars.system_databases) %}
{% set _stale_dbs = salt['ss.list_diff'](_stale_dbs, role.vars.databases.keys()) %}

{% for _stale_db in _stale_dbs %}
mariadb/cleanup/database/{{ _stale_db }}:
  mysql_database.absent:
    - name: {{ _stale_db|yaml_dquote }}
    - connection_host: 'localhost'
    - connection_user: 'root'
    - connection_charset: 'utf8'
    - require:
      - sls: mariadb.databases
{% endfor %}

{% set _active_users = [] %}
{% for _user_name, _user in role.vars.users|dictsort %}
  {% set _user = salt['ss.merge_recursive'](role.vars.user_defaults, _user) %}
  {% for _user_host in _user.hosts %}
    {% do _active_users.append({
      'Host': _user_host,
      'User': _user_name,
    }) %}
  {% endfor %}
{% endfor %}

{% set _stale_users = salt['mysql.user_list']() %}
{% set _stale_users = salt['ss.dict_list_diff'](_stale_users, role.vars.system_users) %}
{% set _stale_users = salt['ss.dict_list_diff'](_stale_users, _active_users) %}

{% for _stale_user in _stale_users %}
mariadb/cleanup/user/{{ _stale_user.User }}-{{ _stale_user.Host }}:
  mysql_user.absent:
    - name: {{ _stale_user.User|yaml_dquote }}
    - host: {{ _stale_user.Host|yaml_dquote }}
    - connection_host: 'localhost'
    - connection_user: 'root'
    - connection_charset: 'utf8'
    - require:
      - sls: mariadb.users
{% endfor %}

{% for _user_name, _user in role.vars.users|dictsort %}
{% set _user = salt['ss.merge_recursive'](role.vars.user_defaults, _user) %}
{% for _user_host in _user.hosts %}

{% set _stale_grants = {} %}

{% set _current_grants = salt['mysql.user_grants'](_user_name, _user_host) %}
{% for _current_grant in _current_grants %}
  {% set _current_grant = salt['mysql.tokenize_grant'](_current_grant) %}
  {% set _grant_target = _current_grant.database|replace('`', '') %}
  {% set _grant_privileges = _current_grant.grant|map('upper')|list %}
  {% set _grant_privileges = salt['ss.list_diff'](_grant_privileges, ['USAGE']) %}

  {% do _stale_grants.update({_grant_target: _grant_privileges}) %}
{% endfor %}

{% for _user_grant in _user.grants %}
  {% set _grant_target = parse_grant_target(_user_grant) %}
  {% set _grant_privileges = _user_grant.privileges|map('upper')|list %}

  {% do _stale_grants.update({
    _grant_target: salt['ss.list_diff'](_stale_grants.get(_grant_target, []), _grant_privileges)
  }) %}
{% endfor %}

{% for _grant_target, _grant_privileges in _stale_grants|dictsort %}
{% if _grant_privileges %}

mariadb/cleanup/user/{{ _user_name }}-{{ _user_host }}/grants/{{ loop.index }}:
  mysql_grants.absent:
    - user: {{ _user_name|yaml_dquote }}
    - host: {{ _user_host|yaml_dquote }}
    - database: {{ _grant_target|yaml_dquote }}
    - grant: {{ _grant_privileges|join(',')|yaml_dquote }}
    - connection_host: 'localhost'
    - connection_user: 'root'
    - connection_charset: 'utf8'
    - require:
      - sls: mariadb.users

{% endif %}
{% endfor %}

{% endfor %}
{% endfor %}
