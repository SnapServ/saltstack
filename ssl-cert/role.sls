{% from slspath ~ '/init.sls' import role, account %}

ssl-cert/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}

{% if role.vars.certificates.keys() %}
ssl-cert/acme.sh/source:
  file.directory:
    - name: {{ role.vars.acmesh_source_dir|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0755'
    - makedirs: true

  git.latest:
    - name: {{ role.vars.acmesh_repository|yaml_dquote }}
    - rev: {{ role.vars.acmesh_revision|yaml_dquote }}
    - target: {{ role.vars.acmesh_source_dir|yaml_dquote }}
    - user: 'root'
    - update_head: true
    - force_checkout: true
    - force_clone: true
    - force_fetch: true
    - force_reset: true
    - require:
      - pkg: ssl-cert/packages
      - file: ssl-cert/acme.sh/source

ssl-cert/acme.sh/install:
  file.directory:
    - name: {{ role.vars.acmesh_install_dir|yaml_dquote }}
    - user: {{ role.vars.service_user|yaml_dquote }}
    - group: {{ role.vars.service_group|yaml_dquote }}
    - mode: '0750'
    - makedirs: true
    - require:
      - {{ account.role.resource('user', role.vars.service_user) }}
      - {{ account.role.resource('group', role.vars.service_group) }}

  cmd.run:
    - name: >-
        {{ (role.vars.acmesh_source_dir ~ '/acme.sh')|quote }}
        --install
        --home {{ role.vars.acmesh_install_dir|quote }}
    - runas: {{ role.vars.service_user|yaml_dquote }}
    - cwd: {{ role.vars.acmesh_source_dir|yaml_dquote }}
    - shell: '/bin/bash'
    - use_vt: true
    - unless: >-
        cmp --silent
        <(tail -n+2 {{ (role.vars.acmesh_source_dir ~ '/acme.sh')|quote }})
        <(tail -n+2 {{ (role.vars.acmesh_install_dir ~ '/acme.sh')|quote }})
    - require:
      - file: ssl-cert/acme.sh/install
      - git: ssl-cert/acme.sh/source

{% set _all_dependencies = [] %}
{% for _cert_name, _cert in role.vars.certificates|dictsort %}
{% if _cert.get('managed', true) %}

{% set _cert_state_cmd = [
  (role.vars.acmesh_install_dir ~ '/acme.sh')|quote, '--list', '--listraw',
  '|', 'grep', ('^' ~ _cert_name)|quote
]|join(' ') %}

{% set _cert_state = salt['cmd.run'](
  cmd=_cert_state_cmd,
  runas=role.vars.service_user,
  cwd=role.vars.acmesh_install_dir,
  python_shell=true,
  shell='/bin/bash',
  env=[{'LE_WORKING_DIR': role.vars.acmesh_install_dir}]
) %}

ssl-cert/acme.sh/issue/{{ _cert_name }}:
  cmd.run:
    - name: >-
        {{ (role.vars.acmesh_install_dir ~ '/acme.sh')|quote }}
        --issue --dns dns_acmedns --dnssleep 0
        --accountkeylength 4096 --keylength 4096
        --domain {{ ([_cert_name] + _cert.domains)|map('quote')|join(' --domain ') }}
    - env:
      - LE_WORKING_DIR: {{ role.vars.acmesh_install_dir|yaml_dquote }}
      - ACMEDNS_UPDATE_URL: {{ role.vars.acmedns_update_url|yaml_dquote }}
      - ACMEDNS_USERNAME: {{ _cert.acmedns_username|yaml_dquote }}
      - ACMEDNS_PASSWORD: {{ _cert.acmedns_password|yaml_dquote }}
      - ACMEDNS_SUBDOMAIN: {{ _cert.acmedns_subdomain|yaml_dquote }}
    - runas: {{ role.vars.service_user|yaml_dquote }}
    - cwd: {{ role.vars.acmesh_install_dir|yaml_dquote }}
    - use_vt: true
    - success_retcodes: [2]
    - require:
      - cmd: ssl-cert/acme.sh/install

{% for _cert_perm in _cert.get('install_permissions', []) %}
{% set _directory = _cert_perm.get('directory', false) %}

ssl-cert/acme.sh/install/{{ _cert_name }}-{{ loop.index }}:
  file.{{ 'directory' if _directory else 'managed' }}:
    - name: {{ _cert_perm.target|yaml_dquote }}
    - user: {{ _cert_perm.get('user', none)|yaml_encode }}
    - group: {{ _cert_perm.get('group', none)|yaml_encode }}
    - mode: {{ _cert_perm.get('mode', none)|yaml_encode }}
    - makedirs: true
    {% if not _directory %}
    - replace: false
    {% endif %}
    - require_in:
      - cmd: ssl-cert/acme.sh/install/{{ _cert_name }}
{% endfor %}

{% set _dependencies = _cert.get('install_depends', []) %}
{% do _all_dependencies.extend(_dependencies) %}

ssl-cert/acme.sh/install/{{ _cert_name }}:
  cmd.run:
    - name: >-
        {{ (role.vars.acmesh_install_dir ~ '/acme.sh')|quote }}
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
        {%- if 'install_command' in _cert %}
        --reloadcmd {{ _cert.install_command|quote }}
        {%- endif %}
    - env:
      - LE_WORKING_DIR: {{ role.vars.acmesh_install_dir|yaml_dquote }}
    - runas: {{ role.vars.service_user|yaml_dquote }}
    - cwd: {{ role.vars.acmesh_install_dir|yaml_dquote }}
    - use_vt: true
    - unless: >-
        test "$({{ _cert_state_cmd }})" = {{ _cert_state|quote }}
    {% if _dependencies %}
    - require:
    {% for _dependency in _dependencies %}
      - sls: {{ _dependency ~ '.role' }}
    {% endfor %}
    {% endif %}
    - onchanges:
      - cmd: ssl-cert/acme.sh/issue/{{ _cert_name }}
{% else %}
ssl-cert/acme.sh/remove/{{ _cert_name }}:
  cmd.run:
    - name: >-
        {{ (role.vars.acmesh_install_dir ~ '/acme.sh')|quote }}
        --remove --domain {{ _cert_name|quote }}
    - env:
      - LE_WORKING_DIR: {{ role.vars.acmesh_install_dir|yaml_dquote }}
    - runas: {{ role.vars.service_user|yaml_dquote }}
    - cwd: {{ role.vars.acmesh_install_dir|yaml_dquote }}
    - use_vt: true
    - require:
      - cmd: ssl-cert/acme.sh/install
{% endif %}
{% endfor %}

include: {{ _all_dependencies|yaml }}
{% endif %}

ssl-cert/snakeoil:
  cmd.run:
    - name: {{ role.vars.snakeoil_regenerate_cmd|yaml_dquote }}
    - unless: {{ role.vars.snakeoil_verify_cmd.format(
        certificate=role.vars.snakeoil_certificate_path|quote,
      )|yaml_dquote }}
    - require:
      - pkg: ssl-cert/packages
