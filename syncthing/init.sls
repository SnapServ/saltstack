{% set role = salt['ss.role']('syncthing') %}
{% import role.dependency('account') as account %}{% set account = account %}
{% import role.dependency('software') as software %}{% set software = software %}

{% do role.add_include('global') %}
{% do role.add_include('instances') %}

include: {{ role.includes|yaml }}
