{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import ssl_cert %}

ssl-cert/acme.sh/packages:
  pkg.installed:
    - pkgs: {{ ssl_cert.acmesh_packages|yaml }}

ssl-cert/acme.sh/source:
  file.directory:
    - name: {{ ssl_cert.acmesh_source_dir|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0755'
    - makedirs: true

  git.latest:
    - name: {{ ssl_cert.acmesh_repository|yaml_dquote }}
    - rev: {{ ssl_cert.acmesh_revision|yaml_dquote }}
    - target: {{ ssl_cert.acmesh_source_dir|yaml_dquote }}
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
    - name: {{ ssl_cert.acmesh_install_dir|yaml_dquote }}
    - user: {{ ssl_cert.service_user|yaml_dquote }}
    - group: {{ ssl_cert.service_group|yaml_dquote }}
    - mode: '0750'
    - makedirs: true
    - require:
      - {{ stdlib.resource_dep('system-user', ssl_cert.service_user) }}
      - {{ stdlib.resource_dep('system-group', ssl_cert.service_group) }}

  cmd.run:
    - name: >-
        {{ (ssl_cert.acmesh_source_dir ~ '/acme.sh')|quote }}
        --install
        --home {{ ssl_cert.acmesh_install_dir|quote }}
    - runas: {{ ssl_cert.service_user|yaml_dquote }}
    - cwd: {{ ssl_cert.acmesh_source_dir|yaml_dquote }}
    - shell: '/bin/bash'
    - use_vt: true
    - unless: >-
        cmp --silent
        <(tail -n+2 {{ (ssl_cert.acmesh_source_dir ~ '/acme.sh')|quote }})
        <(tail -n+2 {{ (ssl_cert.acmesh_install_dir ~ '/acme.sh')|quote }})
    - require:
      - file: ssl-cert/acme.sh/install
      - git: ssl-cert/acme.sh/source
