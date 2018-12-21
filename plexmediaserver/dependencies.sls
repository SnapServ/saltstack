{% set role = salt['ssx.role_data']('plexmediaserver') %}
{% from 'software/macros.sls' import repository_macro %}

include:
  - software

{{ repository_macro('plexmediaserver', {
  'sources': role.repository_sources,
  'gpg_key_url': role.repository_gpg_key_url,
}) }}
