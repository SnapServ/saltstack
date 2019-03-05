{% set role = salt['ss.role']('account') %}

{% if role.vars.managed %}
include:
  - {{ sls }}.groups
  - {{ sls }}.users
  - {{ sls }}.sshkeys
{% endif %}
