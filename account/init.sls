{%- set account = {} %}

{%- import 'stdlib.jinja' as stdlib %}
{{- stdlib.formula_config(tpldir, account) }}

{%- if account.managed %}
include:
  - .users
  - .groups
  - .ssh_keys
{%- endif %}
