{% set role = salt['custom.role_data']('account') %}

{% if role.managed %}
include:
  - {{ sls }}.groups
  - {{ sls }}.users
  - {{ sls }}.sshkeys
{% endif %}
