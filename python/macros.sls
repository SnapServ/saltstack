{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import python %}

{##############################################################################
 ## python_virtualenv
 ##############################################################################}
{%- macro python_virtualenv(name, path) %}

{#- Generate state ID and declare formula resource #}
{%- set _venv_sid = 'python/virtualenv/' ~ name %}
{{- stdlib.formula_resource(tpldir, 'python-virtualenv', name) }}

{#- Declare virtual environment #}
{{ _venv_sid|yaml_dquote }}:
  virtualenv.managed:
    - name: {{ path|yaml_dquote }}
    - python: {{ python.python_bin|yaml_dquote }}
    - user: {{ kwargs.get('user', none)|yaml_encode }}
    - requirements: {{ kwargs.get('requirements', none)|yaml_encode }}
    - pip_pkgs: {{ kwargs.get('pip_pkgs', none)|yaml }}
    - pip_upgrade: {{ kwargs.get('pip_upgrade', false)|yaml_encode }}
    - venv_bin: {{ python.venv_wrapper_bin|yaml_dquote }}
    - onchanges_in:
      - {{ stdlib.resource_dep('python-virtualenv', name) }}
    - require:
      - pkg: python/packages
      - file: python/venv-wrapper
      {%- for _requirement in kwargs.get('require', []) %}
      - {{ _requirement|yaml }}
      {%- endfor %}
{%- endmacro %}
