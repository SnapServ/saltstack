{% from slspath ~ '/init.sls' import role, software %}

{{ software.repository(
  state_id='prosody/repository',
  name='prosody'
  sources=role.vars.repository_sources,
  gpg_key_url=role.vars.repository_gpg_key_url,
) }}

prosody/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}
    - require:
      - prosody/repository

prosody/service:
  service.running:
    - name: {{ role.vars.service|yaml_dquote }}
    - enable: True
    - require:
      - pkg: prosody/packages
