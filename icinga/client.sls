{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import icinga %}

{%- if not icinga.master_cert %}
  {{ salt['test.exception']('icinga.master_cert must be configured') }}
{%- endif %}

include:
  - .common

icinga/client/wipe-local-config:
  file.directory:
    - name: {{ icinga.config_dir|yaml_dquote }}
    - clean: True
    - watch_in:
      - service: icinga/service

icinga/client/zones-config: &zones-config
  file.managed:
    - name: {{ icinga.zones_config|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['client/zones.conf.j2'],
        lookup='client-zones-config'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        icinga: {{ icinga|yaml }}
    - require:
      - file: icinga/client/wipe-local-config
    - watch_in:
      - service: icinga/service

{%- set _node_cert_path = icinga.certs_dir ~ '/' ~ grains['fqdn'] ~ '.crt' %}
{%- if not salt['file.file_exists'](_node_cert_path) %}

icinga/client/cleanup:
  file.directory:
    - name: {{ icinga.certs_dir|yaml_dquote }}
    - clean: True

icinga/client/deploy-master-cert:
  file.managed:
    - name: {{ icinga.master_cert_path|yaml_dquote }}
    - contents: {{ icinga.master_cert|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - require:
      - file: icinga/client/cleanup

icinga/client/join:
  cmd.run:
    - name: >-
        {{ icinga.icinga_bin|quote }} node setup
        --cn {{ grains['fqdn']|quote }}
        --zone {{ grains['fqdn']|quote }}
        --parent_host {{ icinga.master_fqdn|quote }}
        --endpoint {{ icinga.master_fqdn|quote }}
        --trustedcert {{ icinga.master_cert_path|quote }}
        --accept-commands
    - require:
      - file: icinga/client/deploy-master-cert
    - require_in:
      - file: icinga/client/zones-config
    - watch_in:
      - service: icinga/service

{%- endif %}
