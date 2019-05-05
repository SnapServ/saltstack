{% from slspath ~ '/init.sls' import role %}

{% if not role.vars.master_cert %}
  {{ salt['test.exception']('icinga.master_cert must be configured') }}
{% endif %}

include:
  - .common

icinga/client/wipe-local-config:
  file.directory:
    - name: {{ role.vars.config_dir|yaml_dquote }}
    - clean: true
    - watch_in:
      - service: icinga/service

icinga/client/zones-config: &zones-config
  file.managed:
    - name: {{ role.vars.zones_config|yaml_dquote }}
    - source: {{ role.tpl_path('client/zones.conf.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - file: icinga/client/wipe-local-config
    - watch_in:
      - service: icinga/service

{% set _node_cert_path = role.vars.certs_dir ~ '/' ~ grains['fqdn'] ~ '.crt' %}
{% if not salt['file.file_exists'](_node_cert_path) %}

icinga/client/cleanup:
  file.directory:
    - name: {{ role.vars.certs_dir|yaml_dquote }}
    - clean: true

icinga/client/deploy-master-cert:
  file.managed:
    - name: {{ role.vars.master_cert_path|yaml_dquote }}
    - contents: {{ role.vars.master_cert|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - require:
      - file: icinga/client/cleanup

icinga/client/join:
  cmd.run:
    - name: >-
        {{ role.vars.icinga_bin|quote }} node setup
        --cn {{ grains['fqdn']|quote }}
        --zone {{ grains['fqdn']|quote }}
        --parent_host {{ role.vars.master_fqdn|quote }}
        --endpoint {{ role.vars.master_fqdn|quote }}
        --trustedcert {{ role.vars.master_cert_path|quote }}
        --accept-commands
    - require:
      - file: icinga/client/deploy-master-cert
    - require_in:
      - file: icinga/client/zones-config
    - watch_in:
      - service: icinga/service

{% endif %}
