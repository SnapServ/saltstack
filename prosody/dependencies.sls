{% from slspath ~ '/init.sls' import role %}
{% import 'software/macros.sls' as software %}

include:
  - software

{{ software.declare_repository('prosody', {
  'sources': role.vars.repository_sources,
  'gpg_key_url': role.vars.repository_gpg_key_url,
}) }}
