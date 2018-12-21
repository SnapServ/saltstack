{% set role = salt['ssx.role_data']('software') %}

software/dependencies:
  pkg.installed:
    - pkgs: {{ role.dependencies|yaml }}

{% for _state in ['installed', 'latest', 'removed', 'purged'] %}
software/packages/{{ _state }}:
  pkg.{{ _state }}:
    - pkgs: {{ role.packages[_state]|yaml }}
    - require:
      - pkg: software/dependencies
{% endfor %}
