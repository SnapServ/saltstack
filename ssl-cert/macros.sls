{%- set role = salt['custom.role_data']('ssl-cert') -%}

{%- macro safe_certificate(_path) -%}
  {%- if salt['file.exists'](_path) -%}
    {{- _path -}}
  {%- else %}
    {{- role.snakeoil_certificate_path -}}
  {%- endif -%}
{%- endmacro -%}

{%- macro safe_keyfile(_path) -%}
  {%- if salt['file.exists'](_path) -%}
    {{- _path -}}
  {%- else %}
    {{- role.snakeoil_keyfile_path -}}
  {%- endif -%}
{%- endmacro -%}
