{% from slspath ~ '/init.sls' import role, software %}

{% for _repository_name, _repository in role.vars.repositories|dictsort %}
  {{- software.repository(_repository_name, **_repository) -}}
{% endfor %}
