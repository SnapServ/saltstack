{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import prosody %}
{%- from stdlib.formula_macros('software') import software_repository %}

include:
  - software

{{ software_repository(
  name='prosody',
  sources=prosody.repository_sources,
  gpg_key_url=prosody.repository_gpg_key_url,
) }}

{%- set _community_modules_repo_dir = prosody.community_modules_dir ~ '/.repository' %}

prosody/packages:
  pkg.installed:
    - pkgs: {{ prosody.packages|yaml }}
    - require:
      - {{ stdlib.resource_dep('software-repository', 'prosody') }}

prosody/community-modules-dir:
  file.directory:
    - name: {{ prosody.community_modules_dir|yaml_dquote }}
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
    - rev: {{ prosody.community_modules_revision|yaml_dquote }}
    - clean: true
    - force: true
    - require:
      - file: prosody/community-modules-repo
    - watch_in:
      - service: prosody/service

{% for _module in prosody.community_modules|sort %}
prosody/community-modules/{{ _module }}:
  file.symlink:
    - name: {{ (prosody.community_modules_dir ~ '/mod_' ~ _module)|yaml_dquote }}
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
    - name: {{ prosody.config_path|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['prosody.cfg.lua.j2'],
        lookup='prosody-config'
      ) }}
    - template: 'jinja'
    - user: {{ prosody.service_user|yaml_dquote }}
    - group: {{ prosody.service_group|yaml_dquote }}
    - mode: '0640'
    - context:
        prosody: {{ prosody|yaml }}
    - require:
      - pkg: prosody/packages
    - watch_in:
      - service: prosody/service

prosody/service:
  service.running:
    - name: {{ prosody.service|yaml_dquote }}
    - enable: True
    - reload: True
    - require:
      - pkg: prosody/packages
