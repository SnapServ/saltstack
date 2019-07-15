{% from slspath ~ '/init.sls' import role, software %}

strongswan/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}

strongswan/daemon-config:
  file.managed:
    - name: {{ role.vars.daemon_config_path|yaml_dquote }}
    - source: {{ role.tpl_path('ipsec.conf.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - pkg: strongswan/packages

strongswan/secrets-config:
  file.managed:
    - name: {{ role.vars.secrets_config_path|yaml_dquote }}
    - source: {{ role.tpl_path('ipsec.secrets.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0600'
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - pkg: strongswan/packages

strongswan/secrets/pubkey-public-dir:
  file.directory:
    - name: {{ role.vars.pubkey_public_path|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0700'
    - clean: true
    - watch_in:
      - service: strongswan/service

strongswan/secrets/pubkey-private-dir:
  file.directory:
    - name: {{ role.vars.pubkey_private_path|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0700'
    - clean: true
    - watch_in:
      - service: strongswan/service

{% for _pubkey_name, _pubkey in role.vars.pubkeys|dictsort %}
{% if 'public' in _pubkey %}
strongswan/secrets/pubkey/{{ _pubkey_name }}-public:
  file.managed:
    - name: {{ (role.vars.pubkey_public_path ~ '/' ~ _pubkey_name ~ '.pem')|yaml_dquote }}
    - contents: {{ _pubkey.public|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0600'
    - makedir: true
    - require_in:
      - file: strongswan/secrets/pubkey-public-dir
    - watch_in:
      - service: strongswan/service
    - require:
      - pkg: strongswan/packages
{% endif %}

{% if 'private' in _pubkey %}
strongswan/secrets/pubkey/{{ _pubkey_name }}-private:
  file.managed:
    - name: {{ (role.vars.pubkey_private_path ~ '/' ~ _pubkey_name ~ '.pem')|yaml_dquote }}
    - contents: {{ _pubkey.private|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0600'
    - makedir: true
    - require_in:
      - file: strongswan/secrets/pubkey-private-dir
    - watch_in:
      - service: strongswan/service
    - require:
      - pkg: strongswan/packages
{% endif %}
{% endfor %}

strongswan/service:
  service.running:
    - name: {{ role.vars.service|yaml_dquote }}
    - enable: True
    - reload: True
    - watch:
      - file: strongswan/daemon-config
      - file: strongswan/secrets-config
