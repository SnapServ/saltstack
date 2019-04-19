{% set role = salt['ss.role']('ssl-cert') %}
{% import role.dependency('account') as account %}{% set account = account %}

{% set _certificate_count = role.vars.certificates.keys()|count %}
{% do role.add_include_if(_certificate_count > 0, 'acmesh') %}
{% do role.add_include_if(_certificate_count > 0, 'certificates') %}
{% do role.add_include('snakeoil') %}

include: {{ role.includes|yaml }}
