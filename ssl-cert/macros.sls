{%- set role = salt['ss.role']('ssl-cert') -%}

{%- macro safe_certificate(_path) -%}
  {%- if salt['file.file_exists'](_path) -%}
    {{- _path -}}
  {%- else %}
    {{- role.vars.snakeoil_certificate_path -}}
  {%- endif -%}
{%- endmacro -%}

{%- macro safe_keyfile(_path) -%}
  {%- if salt['file.file_exists'](_path) -%}
    {{- _path -}}
  {%- else %}
    {{- role.vars.snakeoil_keyfile_path -}}
  {%- endif -%}
{%- endmacro -%}
