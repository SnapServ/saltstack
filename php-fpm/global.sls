{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import php_fpm %}
{%- from stdlib.formula_macros('software') import software_repository %}

include:
  - software

{%- for _repository_name, _repository in php_fpm.repositories|dictsort %}
  {{- software_repository(_repository_name, **_repository) -}}
{%- endfor %}
