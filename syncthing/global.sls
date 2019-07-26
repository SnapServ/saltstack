{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import syncthing %}
{%- from stdlib.formula_macros('software') import software_repository %}

include:
  - software

{{ software_repository(
  name='syncthing',
  sources=syncthing.repository_sources,
  gpg_key_url=syncthing.repository_gpg_key_url,
) }}

syncthing/packages:
  pkg.installed:
    - pkgs: {{ syncthing.packages|yaml }}
    - require:
      - {{ stdlib.resource_dep('software-repository', 'syncthing') }}
