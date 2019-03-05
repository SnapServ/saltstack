{% from slspath ~ '/init.sls' import role %}
{% import 'software/macros.sls' as software %}

include:
  - software

{% for _repository_name, _repository in role.vars.repositories|dictsort %}
  {{- software.declare_repository(_repository_name, _repository) -}}
{% endfor %}
