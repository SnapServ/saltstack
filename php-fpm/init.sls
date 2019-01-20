{% set role = salt['custom.role_data']('php-fpm') %}

{% if role.managed %}
include:
  - {{ sls }}.global
  - {{ sls }}.versions
{% endif %}
