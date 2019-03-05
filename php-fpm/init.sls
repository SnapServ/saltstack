{% set role = salt['ss.role']('php-fpm') %}

{% if role.vars.managed %}
include:
  - {{ sls }}.global
  - {{ sls }}.versions
{% endif %}
