{% from slspath ~ '/init.sls' import role %}

python/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}

python/venv-wrapper:
  file.managed:
    - name: {{ role.vars.venv_wrapper_bin|yaml_dquote }}
    - source: {{ role.tpl_path('venv-wrapper.sh.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0755'
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - pkg: python/packages
