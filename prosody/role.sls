{% from slspath ~ '/init.sls' import role, software %}
{% set _community_modules_repo_dir = role.vars.community_modules_dir ~ '/.repository' %}

{{ software.repository(
  state_id='prosody/repository',
  name='prosody',
  sources=role.vars.repository_sources,
  gpg_key_url=role.vars.repository_gpg_key_url,
) }}

prosody/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}
    - require:
      - prosody/repository

prosody/community-modules-dir:
  file.directory:
    - name: {{ role.vars.community_modules_dir|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0755'
    - clean: true

prosody/community-modules-repo:
  file.directory:
    - name: {{ _community_modules_repo_dir|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0755'
    - makedirs: true
    - require_in:
      - file: prosody/community-modules-dir

  hg.latest:
    - name: 'https://hg.prosody.im/prosody-modules/'
    - target: {{ _community_modules_repo_dir|yaml_dquote }}
    - rev: {{ role.vars.community_modules_revision|yaml_dquote }}
    - clean: true
    - force: true
    - require:
      - file: prosody/community-modules-repo
    - watch_in:
      - service: prosody/service

{% for _module in role.vars.community_modules|sort %}
prosody/community-modules/{{ _module }}:
  file.symlink:
    - name: {{ (role.vars.community_modules_dir ~ '/mod_' ~ _module)|yaml_dquote }}
    - target: {{ (_community_modules_repo_dir ~ '/mod_' ~ _module)|yaml_dquote }}
    - force: true
    - require:
      - hg: prosody/community-modules-repo
    - require_in:
      - file: prosody/community-modules-dir
    - watch_in:
      - service: prosody/service
{% endfor %}

prosody/config:
  file.managed:
    - name: {{ role.vars.config_path|yaml_dquote }}
    - source: {{ role.tpl_path('prosody.cfg.lua.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: {{ role.vars.service_user|yaml_dquote }}
    - group: {{ role.vars.service_group|yaml_dquote }}
    - mode: '0640'
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - pkg: prosody/packages
    - watch_in:
      - service: prosody/service

prosody/service:
  service.running:
    - name: {{ role.vars.service|yaml_dquote }}
    - enable: True
    - require:
      - pkg: prosody/packages
