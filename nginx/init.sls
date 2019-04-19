{% set role = salt['ss.role']('nginx') %}
{% import role.dependency('ssl-cert') as sslcert %}{% set sslcert = sslcert %}
{% do role.add_include('global') %}
{% do role.add_include('vhosts') %}

include: {{ role.includes|yaml }}
