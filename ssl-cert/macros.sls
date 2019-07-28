{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import ssl_cert %}

{%- macro snakeoil_certificate() -%}
  {{- ssl_cert.snakeoil_certificate_path -}}
{%- endmacro -%}

{%- macro snakeoil_keyfile() -%}
  {{- ssl_cert.snakeoil_keyfile_path -}}
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
