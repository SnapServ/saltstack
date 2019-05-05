{% set role = salt['ss.role']('icinga') %}
{% do role.add_include('common') %}
{% do role.add_include_if(grains['fqdn'] == role.vars.master_fqdn, 'master') %}
{% do role.add_include_if(grains['fqdn'] != role.vars.master_fqdn, 'client') %}

{% if not role.vars.master_fqdn %}
  {{ salt['test.exception']('icinga.master_fqdn must be configured') }}
{% endif %}

include: {{ role.includes|yaml }}
