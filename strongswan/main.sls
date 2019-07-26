{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import strongswan %}

strongswan/packages:
  pkg.installed:
    - pkgs: {{ strongswan.packages|yaml }}

strongswan/daemon-config:
  file.managed:
    - name: {{ strongswan.daemon_config_path|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['ipsec.conf.j2'],
        lookup='ipsec-config'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        strongswan: {{ strongswan|yaml }}
    - require:
      - pkg: strongswan/packages

strongswan/secrets-config:
  file.managed:
    - name: {{ strongswan.secrets_config_path|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['ipsec.secrets.j2'],
        lookup='ipsec-secrets'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0600'
    - context:
        strongswan: {{ strongswan|yaml }}
    - require:
      - pkg: strongswan/packages

strongswan/secrets/pubkey-public-dir:
  file.directory:
    - name: {{ strongswan.pubkey_public_path|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0700'
    - clean: True
    - watch_in:
      - service: strongswan/service

strongswan/secrets/pubkey-private-dir:
  file.directory:
    - name: {{ strongswan.pubkey_private_path|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0700'
    - clean: True
    - watch_in:
      - service: strongswan/service

{%- for _pubkey_name, _pubkey in strongswan.pubkeys|dictsort %}
{%- if 'public' in _pubkey %}
strongswan/secrets/pubkey/{{ _pubkey_name }}-public:
  file.managed:
    - name: {{ (strongswan.pubkey_public_path ~ '/' ~ _pubkey_name ~ '.pem')|yaml_dquote }}
    - contents: {{ _pubkey.public|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0600'
    - makedir: True
    - require_in:
      - file: strongswan/secrets/pubkey-public-dir
    - watch_in:
      - service: strongswan/service
    - require:
      - pkg: strongswan/packages
{%- endif %}

{%- if 'private' in _pubkey %}
strongswan/secrets/pubkey/{{ _pubkey_name }}-private:
  file.managed:
    - name: {{ (strongswan.pubkey_private_path ~ '/' ~ _pubkey_name ~ '.pem')|yaml_dquote }}
    - contents: {{ _pubkey.private|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0600'
    - makedir: True
    - require_in:
      - file: strongswan/secrets/pubkey-private-dir
    - watch_in:
      - service: strongswan/service
    - require:
      - pkg: strongswan/packages
{%- endif %}
{%- endfor %}

strongswan/service:
  service.running:
    - name: {{ strongswan.service|yaml_dquote }}
    - enable: True
    - reload: True
    - watch:
      - file: strongswan/daemon-config
      - file: strongswan/secrets-config
