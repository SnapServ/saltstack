{% set role = salt['ssx.role_data']('account') %}

{% if role.managed %}
include:
  - {{ sls }}.groups
  - {{ sls }}.users
  - {{ sls }}.sshkeys
{% endif %}
