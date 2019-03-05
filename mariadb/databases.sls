{% from slspath ~ '/init.sls' import role %}

include:
  - .server

{% for _database_name, _database in role.vars.databases|dictsort %}
{% set _database = salt['ss.merge_recursive'](role.vars.database_defaults, _database) %}

mariadb/database/{{ _database_name }}:
  mysql_database.present:
    - name: {{ _database_name|yaml_dquote }}
    - character_set: {{ _database.character_set|yaml_dquote }}
    - collate: {{ _database.collate|yaml_dquote }}
    - connection_host: 'localhost'
    - connection_user: 'root'
    - connection_charset: 'utf8'
    - require:
      - service: mariadb/server/service
{% endfor %}
