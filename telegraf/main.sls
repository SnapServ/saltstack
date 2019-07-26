{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import telegraf %}
{%- from stdlib.formula_macros('software') import software_repository %}

include:
  - software/

{{ software_repository(
  name='influxdata',
  sources=telegraf.repository_sources,
  gpg_key_url=telegraf.repository_gpg_key_url,
) }}

telegraf/packages:
  pkg.installed:
    - pkgs: {{ telegraf.packages|yaml }}
    - require:
      - {{ stdlib.resource_dep('software-repository', 'influxdata') }}

telegraf/config:
  file.managed:
    - name: {{ telegraf.config_path|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['telegraf.conf.j2'],
        lookup='telegraf-config'
      ) }}
    - check_cmd: {{ telegraf.config_check_cmd|yaml_dquote }}
    - template: 'jinja'
    - user: {{ telegraf.service_user|yaml_dquote }}
    - group: {{ telegraf.service_group|yaml_dquote }}
    - mode: '0640'
    - context:
        telegraf: {{ telegraf|yaml }}
    - require:
      - pkg: telegraf/packages

telegraf/service:
  service.running:
    - name: {{ telegraf.service|yaml_dquote }}
    - enable: True
    - reload: True
    - watch:
      - file: telegraf/config
