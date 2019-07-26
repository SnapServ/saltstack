{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import grafana %}
{%- from stdlib.formula_macros('software') import software_repository %}

include:
  - software

{{ software_repository(
  name='grafana',
  sources=grafana.repository_sources,
  gpg_key_url=grafana.repository_gpg_key_url,
) }}

grafana/packages:
  pkg.installed:
    - pkgs: {{ grafana.packages|yaml }}
    - require:
      - {{ stdlib.resource_dep('software-repository', 'grafana') }}

grafana/service:
  service.running:
    - name: {{ grafana.service|yaml_dquote }}
    - enable: True
    - reload: True
    - require:
      - pkg: grafana/packages
