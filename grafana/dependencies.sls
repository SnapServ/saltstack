{% set role = salt['custom.role_data']('grafana') %}
{% from 'software/macros.sls' import repository_macro %}

include:
  - software

{{ repository_macro('grafana', {
  'sources': role.repository_sources,
  'gpg_key_url': role.repository_gpg_key_url,
}) }}
