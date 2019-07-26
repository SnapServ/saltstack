{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import plexmediaserver %}
{%- from stdlib.formula_macros('software') import software_repository %}

include:
  - software

{{ software_repository(
  name='plexmediaserver',
  sources=plexmediaserver.repository_sources,
  gpg_key_url=plexmediaserver.repository_gpg_key_url,
) }}

plexmediaserver/packages:
  pkg.installed:
    - pkgs: {{ plexmediaserver.packages|yaml }}
    - require:
      - {{ stdlib.resource_dep('software-repository', 'plexmediaserver') }}

plexmediaserver/service:
  service.running:
    - name: {{ plexmediaserver.service|yaml_dquote }}
    - enable: True
    - require:
      - pkg: plexmediaserver/packages
