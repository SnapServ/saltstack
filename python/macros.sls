{% set role = salt['custom.role']('python') %}

{% macro virtualenv(path) %}
{% set _state_id = kwargs.get('state_id', 'python/virtualenv-{0}'.format(path)) %}

{{ _state_id }}:
  virtualenv.managed:
    - name: {{ path|yaml_dquote }}
    - python: {{ role.vars.python_bin|yaml_dquote }}
    - user: {{ kwargs.get('user', none)|yaml_encode }}
    - requirements: {{ kwargs.get('requirements', none)|yaml_encode }}
    - pip_pkgs: {{ kwargs.get('pip_pkgs', none)|yaml }}
    - pip_upgrade: {{ kwargs.get('pip_upgrade', false)|yaml_encode }}
    - require: [{'pkg': 'python/packages'}]
{% endmacro %}
