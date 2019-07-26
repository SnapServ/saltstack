{%- set php_fpm = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, php_fpm) }}

{%- if php_fpm.managed %}
include:
  - .global
  - .versions
{%- endif %}
