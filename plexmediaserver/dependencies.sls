{% from slspath ~ '/init.sls' import role %}
{% from 'software/macros.sls' as software %}

include:
  - software

{{ software.declare_repository('plexmediaserver', {
  'sources': role.repository_sources,
  'gpg_key_url': role.repository_gpg_key_url,
}) }}
