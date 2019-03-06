{% set role = salt['ss.role']('php-fpm') %}
{% do role.add_include('global') %}
{% do role.add_include('versions') %}

include: {{ role.includes|yaml }}
