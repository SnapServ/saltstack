{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import python %}

python/packages:
  pkg.installed:
    - pkgs: {{ python.packages|yaml }}

python/venv-wrapper:
  file.managed:
    - name: {{ python.venv_wrapper_bin|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['venv-wrapper.sh.j2'],
        lookup='venv-wrapper-script'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0755'
    - context:
        python: {{ python|yaml }}
    - require:
      - pkg: python/packages
