{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import ssl_cert %}

{%- macro snakeoil_certificate() -%}
  {{- role.vars.snakeoil_certificate_path -}}
{%- endmacro -%}

{%- macro snakeoil_keyfile() -%}
  {{- role.vars.snakeoil_keyfile_path -}}
{%- endmacro -%}

{%- macro safe_certificate(_path) -%}
  {%- if salt['file.file_exists'](_path) -%}
    {{- _path -}}
  {%- else %}
    {{- snakeoil_certificate() -}}
  {%- endif -%}
{%- endmacro -%}

{%- macro safe_keyfile(_path) -%}
  {%- if salt['file.file_exists'](_path) -%}
    {{- _path -}}
  {%- else %}
    {{- snakeoil_keyfile() -}}
  {%- endif -%}
{%- endmacro -%}
