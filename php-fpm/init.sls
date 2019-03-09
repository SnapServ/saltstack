{% set role = salt['ss.role']('php-fpm') %}
{% import role.dependency('software') as software %}{% set software = software %}

{% do role.add_include('global') %}
{% do role.add_include('versions') %}

include: {{ role.includes|yaml }}
