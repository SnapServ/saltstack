{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import borgbackup %}
{%- from stdlib.formula_macros('python') import python_virtualenv %}

{% set _ssh_hosts_path = borgbackup.service_dir ~ '/ssh-hosts' %}
{% set _ssh_keyfile_path = borgbackup.service_dir ~ '/ssh-keyfile' %}
{% set _passphrase_path = borgbackup.service_dir ~ '/passphrase' %}
{% set _borg_bin = borgbackup.service_dir ~ '/venv/bin/borg' %}
{% set _borgmatic_bin = borgbackup.service_dir ~ '/venv/bin/borgmatic' %}
{% set _borgmatic_config = borgbackup.service_dir ~ '/borgmatic.yaml' %}

include:
  - python

borgbackup/packages:
  pkg.installed:
    - pkgs: {{ borgbackup.packages|yaml }}

borgbackup/directory:
  file.directory:
    - name: {{ borgbackup.service_dir|yaml_dquote }}
    - user: {{ borgbackup.service_user|yaml_dquote }}
    - group: {{ borgbackup.service_group|yaml_dquote }}
    - mode: '0750'

{{ python_virtualenv(
  name='borgbackup',
  path=borgbackup.service_dir ~ '/venv',
  user=borgbackup.service_user,
  pip_pkgs=['borgbackup', 'borgmatic'],
  pip_upgrade=true,
  require=[
    {'pkg': 'borgbackup/packages'},
    {'file': 'borgbackup/directory'}
  ]
) }}

{% set _repo_hosts = [] %}
{% for _repo_host in borgbackup.location.repositories %}
  {% do _repo_hosts.append(_repo_host.split('@')[1].split(':')[0]) %}
{% endfor %}

{% if _repo_hosts %}
borgbackup/ssh-hosts:
  file.managed:
    - name: {{ _ssh_hosts_path|yaml_dquote }}
    - user: {{ borgbackup.service_user|yaml_dquote }}
    - group: {{ borgbackup.service_group|yaml_dquote }}
    - mode: '0600'
    - replace: false
    - require:
      - file: borgbackup/directory  

  cmd.run:
    - name: >-
        {{ borgbackup.ssh_keyscan_bin|quote }}
        {{ _repo_hosts|map('quote')|join(' ') }}
        >{{ _ssh_hosts_path|quote }}
    - runas: {{ borgbackup.service_user|yaml_dquote }}
    - shell: '/bin/sh'
    - umask: '0177'
    - unless: {{ ['test', '-s', _ssh_hosts_path]|map('quote')|join(' ')|yaml_dquote }}
    - require:
      - file: borgbackup/ssh-hosts
{% else %}
borgbackup/ssh-hosts:
  test.configurable_test_state:
    - result: false
    - changes: false
    - comment: 'No remote SSH borgbackup configured'
{% endif %}

borgbackup/ssh-keyfile:
  cmd.run:
    - name: {{ [
        borgbackup.ssh_keygen_bin,
        '-q',
        '-t', 'ed25519', '-a', '100',
        '-N', '',
        '-C', ('borg-ed25519@' ~ grains['fqdn']),
        '-f', _ssh_keyfile_path
      ]|map('quote')|join(' ')|yaml_dquote }}
    - runas: {{ borgbackup.service_user|yaml_dquote }}
    - umask: '0177'
    - creates: {{ _ssh_keyfile_path|yaml_dquote }}
    - require:
      - file: borgbackup/directory

{% if borgbackup.storage.passphrase %}
borgbackup/passphrase:
  file.managed:
    - name: {{ _passphrase_path|yaml_dquote }}
    - contents: {{ borgbackup.storage.passphrase|yaml_dquote }}
    - contents_newline: false
    - user: {{ borgbackup.service_user|yaml_dquote }}
    - group: {{ borgbackup.service_group|yaml_dquote }}
    - mode: '0600'
    - show_changes: false
    - require:
      - file: borgbackup/directory
{% else %}
borgbackup/passphrase:
  test.configurable_test_state:
    - result: false
    - changes: false
    - comment: 'No encryption passphrase configured'
{% endif %}

borgbackup/borgmatic/config:
  file.managed:
    - name: {{ _borgmatic_config|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['borgmatic.yaml'],
        lookup='borgmatic-config'
      ) }}
    - template: 'jinja'
    - user: {{ borgbackup.service_user|yaml_dquote }}
    - group: {{ borgbackup.service_group|yaml_dquote }}
    - mode: '0600'
    - context:
        borgbackup: {{ borgbackup|yaml }}
        borg_bin: {{ _borg_bin|yaml_dquote }}
        ssh_hosts_path: {{ _ssh_hosts_path|yaml_dquote }}
        ssh_keyfile_path: {{ _ssh_keyfile_path|yaml_dquote }}
        passphrase_path: {{ _passphrase_path|yaml_dquote }}
    - require:
      - borgbackup/passphrase
      - cmd: borgbackup/ssh-hosts
      - cmd: borgbackup/ssh-keyfile

borgbackup/initialize:
  cmd.run:
    - name: {{ [
        _borgmatic_bin,
        '--config', _borgmatic_config,
        '--init',
        '--append-only',
        '--encryption', 'repokey-blake2',
      ]|map('quote')|join(' ')|yaml_dquote }}
    - runas: {{ borgbackup.service_user|yaml_dquote }}
    - creates: '/etc/systemd/system/borgmatic.service'
    - use_vty: true
    - require:
      - {{ stdlib.resource_dep('python-virtualenv', 'borgbackup') }}
      - file: borgbackup/borgmatic/config

borgbackup/systemd-service:
  file.managed:
    - name: '/etc/systemd/system/borgmatic.service'
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['borgmatic.service'],
        lookup='borgmatic-service-unit'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        borgbackup: {{ borgbackup|yaml }}
        borgmatic_bin: {{ _borgmatic_bin|yaml_dquote }}
        borgmatic_config: {{ _borgmatic_config|yaml_dquote }}
    - require:
      - cmd: borgbackup/initialize
  
  module.run:
    - name: service.systemctl_reload
    - onchanges:
        - file: borgbackup/systemd-service

borgbackup/systemd-timer:
  file.managed:
    - name: '/etc/systemd/system/borgmatic.timer'
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['borgmatic.timer'],
        lookup='borgmatic-timer-unit'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        borgbackup: {{ borgbackup|yaml }}
    - require:
      - module: borgbackup/systemd-service

  module.run:
    - name: service.systemctl_reload
    - onchanges:
        - file: borgbackup/systemd-timer

  service.running:
    - name: 'borgmatic.timer'
    - enable: true
    - require:
      - module: borgbackup/systemd-timer
