{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import mariadb %}

include:
  - .server

{%- for _database_name, _database in mariadb.databases|dictsort %}

{#- Merge user settings with default settings #}
{%- set _database = salt['defaults.merge'](
  mariadb.database_defaults, _database, in_place=False
) %}

{#- Declare database #}
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

{%- endfor %}
