{% from slspath ~ '/init.sls' import role %}

software/dependencies:
  pkg.installed:
    - pkgs: {{ role.vars.dependencies|yaml }}

{% for _state in ['installed', 'latest', 'removed', 'purged'] %}
software/packages/{{ _state }}:
  pkg.{{ _state }}:
    - pkgs: {{ role.vars.packages[_state]|yaml }}
    - require:
      - pkg: software/dependencies
{% endfor %}
