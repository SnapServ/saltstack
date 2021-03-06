{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import ssl_cert %}

{#- Track list of required formulas / dependencies #}
{%- set _all_dependencies = ['account'] %}

{#- Ensure each declared certificate is issued or removed #}
{%- for _cert_name, _cert in ssl_cert.certificates|dictsort %}
{%- if _cert.get('managed', true) %}

{#- Recursively apply format strings on certificate config #}
{%- set _cert = salt['ss.format_recursive'](_cert, cert_name=_cert_name) %}

{#- Build command for querying the certificate state #}
{%- set _cert_state_cmd = [
  (ssl_cert.acmesh_install_dir ~ '/acme.sh')|quote, '--list', '--listraw',
  '|', 'grep', ('^' ~ _cert_name)|quote
]|join(' ') %}

{#- Determine the current certificate state #}
{%- set _cert_state = salt['cmd.run'](
  cmd=_cert_state_cmd,
  runas=ssl_cert.service_user,
  cwd=ssl_cert.acmesh_install_dir,
  python_shell=true,
  shell='/bin/bash',
  env=[{'LE_WORKING_DIR': ssl_cert.acmesh_install_dir}]
) if salt['file.directory_exists'](ssl_cert.acmesh_install_dir) else '' %}

{#- Build list of domains to be issued #}
{%- set _cert_domains = [_cert_name] + _cert.get('domains', []) %}

{#- Issue the certificate #}
ssl-cert/acme.sh/issue/{{ _cert_name }}:
  cmd.run:
    - name: >-
        {{ (ssl_cert.acmesh_install_dir ~ '/acme.sh')|quote }}
        --issue --dns dns_acmedns --dnssleep 0
        --accountkeylength 4096 --keylength 4096
        --domain {{ _cert_domains|map('quote')|join(' --domain ') }}
    - env:
      - LE_WORKING_DIR: {{ ssl_cert.acmesh_install_dir|yaml_dquote }}
      - ACMEDNS_UPDATE_URL: {{ ssl_cert.acmedns_update_url|yaml_dquote }}
      - ACMEDNS_USERNAME: {{ _cert.acmedns_username|yaml_dquote }}
      - ACMEDNS_PASSWORD: {{ _cert.acmedns_password|yaml_dquote }}
      - ACMEDNS_SUBDOMAIN: {{ _cert.acmedns_subdomain|yaml_dquote }}
    - runas: {{ ssl_cert.service_user|yaml_dquote }}
    - cwd: {{ ssl_cert.acmesh_install_dir|yaml_dquote }}
    - use_vt: true
    - success_retcodes: [2]
    - require:
      - cmd: ssl-cert/acme.sh/install

{#- Collect permissions for all file targets #}
{%- set _cert_perms = _cert.get('install_permissions', []) %}
{%- set _cert_perm_targets = _cert_perms|map(attribute='target') %}

{#- Add default permissions to targets if not explicitly given #}
{%- if 'install_fullchain' in _cert and _cert.install_fullchain not in _cert_perm_targets %}
  {%- do _cert_perms.append({
    'target': _cert.install_fullchain,
    'user': 'root',
    'group': ssl_cert.service_group,
    'mode': '0664'
  }) %}
{%- endif %}
{%- if 'install_certificate' in _cert and _cert.install_certificate not in _cert_perm_targets %}
  {%- do _cert_perms.append({
    'target': _cert.install_certificate,
    'user': 'root',
    'group': ssl_cert.service_group,
    'mode': '0664'
  }) %}
{%- endif %}
{%- if 'install_keyfile' in _cert and _cert.install_keyfile not in _cert_perm_targets %}
  {%- do _cert_perms.append({
    'target': _cert.install_keyfile,
    'user': 'root',
    'group': ssl_cert.service_group,
    'mode': '0660'
  }) %}
{%- endif %}
{%- if 'install_cafile' in _cert and _cert.install_cafile not in _cert_perm_targets %}
  {%- do _cert_perms.append({
    'target': _cert.install_cafile,
    'user': 'root',
    'group': ssl_cert.service_group,
    'mode': '0660'
  }) %}
{%- endif %}

{#- Ensure correct permissions for all installation targets #}
{%- set _cert_perm_targets = _cert_perms|map(attribute='target') %}
{%- for _cert_perm in _cert_perms %}
{%- set _directory = _cert_perm.get('directory', false) %}

ssl-cert/acme.sh/install/{{ _cert_name }}-{{ loop.index }}:
  file.{{ 'directory' if _directory else 'managed' }}:
    - name: {{ _cert_perm.target|yaml_dquote }}
    - user: {{ _cert_perm.get('user', none)|yaml_encode }}
    - group: {{ _cert_perm.get('group', none)|yaml_encode }}
    - mode: {{ _cert_perm.get('mode', none)|yaml_encode }}
    - makedirs: true
    {%- if not _directory %}
    - replace: false
    {%- endif %}
    - require_in:
      - cmd: ssl-cert/acme.sh/install/{{ _cert_name }}
{%- endfor %}

{#- Extend global list of dependencies with certificate dependencies #}
{%- set _dependencies = _cert.get('install_depends', []) %}
{%- do _all_dependencies.extend(_dependencies) %}

{#- Install the certificate using acmesh #}
ssl-cert/acme.sh/install/{{ _cert_name }}:
  cmd.run:
    - name: >-
        {{ (ssl_cert.acmesh_install_dir ~ '/acme.sh')|quote }}
        --install-cert --domain {{ _cert_name|quote }}
        {%- if 'install_fullchain' in _cert %}
        --fullchain-file {{ _cert.install_fullchain|quote }}
        {%- endif %}
        {%- if 'install_certificate' in _cert %}
        --cert-file {{ _cert.install_certificate|quote }}
        {%- endif %}
        {%- if 'install_keyfile' in _cert %}
        --key-file {{ _cert.install_keyfile|quote }}
        {%- endif %}
        {%- if 'install_cafile' in _cert %}
        --ca-file {{ _cert.install_cafile|quote }}
        {%- endif %}
        {%- if 'install_command' in _cert %}
        --reloadcmd {{ _cert.install_command|quote }}
        {%- endif %}
    - env:
      - LE_WORKING_DIR: {{ ssl_cert.acmesh_install_dir|yaml_dquote }}
    - runas: {{ ssl_cert.service_user|yaml_dquote }}
    - cwd: {{ ssl_cert.acmesh_install_dir|yaml_dquote }}
    - use_vt: true
    - unless: >-
        test "$({{ _cert_state_cmd }})" = {{ _cert_state|quote }}
        {{ '-a -s ' if _cert_perm_targets else '' }}
        {{ _cert_perm_targets|map('quote')|join(' -a -s ') }}
    {%- if _dependencies %}
    - require:
      {%- for _dependency in _dependencies %}
      - sls: {{ _dependency ~ '.main' if '.' not in _dependency else _dependency }}
      {%- endfor %}
    {%- endif %}
    - onchanges:
      - cmd: ssl-cert/acme.sh/issue/{{ _cert_name }}

{%- else %}

{#- Remove the certificate using acmesh #}
ssl-cert/acme.sh/remove/{{ _cert_name }}:
  cmd.run:
    - name: >-
        {{ (ssl_cert.acmesh_install_dir ~ '/acme.sh')|quote }}
        --remove --domain {{ _cert_name|quote }}
    - env:
      - LE_WORKING_DIR: {{ ssl_cert.acmesh_install_dir|yaml_dquote }}
    - runas: {{ ssl_cert.service_user|yaml_dquote }}
    - cwd: {{ ssl_cert.acmesh_install_dir|yaml_dquote }}
    - use_vt: true
    - require:
      - cmd: ssl-cert/acme.sh/install

{%- endif %}
{%- endfor %}

include: {{ _all_dependencies|yaml }}
