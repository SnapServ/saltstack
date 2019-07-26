{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import software %}

software/dependencies:
  pkg.installed:
    - pkgs: {{ software.dependencies|yaml }}

{% for _state in ['installed', 'latest', 'removed', 'purged'] %}
software/packages/{{ _state }}:
  pkg.{{ _state }}:
    - pkgs: {{ software.packages[_state]|yaml }}
    - require:
      - pkg: software/dependencies
{% endfor %}

software/remote-packages:
  pkg.installed:
    - sources: {{ software.remote_packages|yaml }}
    - require:
      - pkg: software/dependencies
