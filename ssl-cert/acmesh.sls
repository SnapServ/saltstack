{% from slspath ~ '/init.sls' import role, account %}

ssl-cert/acme.sh/packages:
  pkg.installed:
    - pkgs: {{ role.vars.acmesh_packages|yaml }}

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
      - pkg: ssl-cert/acme.sh/packages
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
