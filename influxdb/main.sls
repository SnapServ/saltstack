{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import influxdb %}
{%- from stdlib.formula_macros('software') import software_repository %}

include:
  - software

{{ software_repository(
  name='influxdata',
  sources=influxdb.repository_sources,
  gpg_key_url=influxdb.repository_gpg_key_url,
) }}

influxdb/packages:
  pkg.installed:
    - pkgs: {{ influxdb.packages|yaml }}
    - require:
      - {{ stdlib.resource_dep('software-repository', 'influxdata') }}

influxdb/service:
  service.running:
    - name: {{ influxdb.service|yaml_dquote }}
    - enable: True
    - reload: True
    - require:
      - pkg: influxdb/packages
