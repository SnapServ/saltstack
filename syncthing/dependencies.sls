{% set role = salt['custom.role_data']('syncthing') %}
{% from 'software/macros.sls' import repository_macro %}

include:
  - software

{{ repository_macro('syncthing', {
  'sources': role.repository_sources,
  'gpg_key_url': role.repository_gpg_key_url,
}) }}
