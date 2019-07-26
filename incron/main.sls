{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import incron %}

incron/packages:
  pkg.installed:
    - pkgs: {{ incron.packages|yaml }}

incron/allowed-users:
  file.managed:
    - name: {{ incron.allowed_users_config|yaml_dquote }}
    - user: 'root'
    - group: {{ incron.config_group|yaml_dquote }}
    - mode: '0640'
    - contents: {{ incron.allowed_users|join('\n')|yaml_dquote }}
    - require:
      - pkg: incron/packages

incron/denied-users:
  file.managed:
    - name: {{ incron.denied_users_config|yaml_dquote }}
    - user: 'root'
    - group: {{ incron.config_group|yaml_dquote }}
    - mode: '0640'
    - contents: {{ incron.denied_users|join('\n')|yaml_dquote }}
    - require:
      - pkg: incron/packages

incron/scripts-dir:
  file.directory:
    - name: {{ incron.scripts_dir|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0755'
    - clean: True
    - require:
      - pkg: incron/packages

{%- for _cron_name, _cron in incron.crons|dictsort %}

{#- Merge cron settings with defaults #}
{%- set _cron = salt['defaults.merge'](
  incron.cron_defaults, _cron, in_place=False
) %}

{#- Generate path to cron script #}
{%- set _cron_script = incron.scripts_dir ~ '/' ~ _cron_name %}

{#- Declare cron script #}
incron/cron/{{ _cron_name }}:
  {%- if _cron.enabled %}
  file.managed:
    - name: {{ _cron_script|yaml_dquote }}
    - user: {{ _cron.user|yaml_dquote }}
    - group: 'root'
    - mode: '0560'
    - contents: {{ _cron.script|yaml_dquote }}
    - require_in:
      - file: incron/scripts-dir

  incron.present:
    - name: {{ _cron_name|yaml_dquote }}
    - user: {{ _cron.user|yaml_dquote }}
    - path: {{ _cron.path|yaml_dquote }}
    - mask: {{ _cron.mask|yaml }}
    - cmd: {{ (_cron_script ~ ' $@/$# $% $&')|yaml_dquote }}
    - require:
      - file: incron/allowed-users
      - file: incron/denied-users
  {%- else %}
  incron.absent:
    - name: {{ _cron_name|yaml_dquote }}
    - user: {{ _cron.user|yaml_dquote }}
    - path: {{ _cron.path|yaml_dquote }}
    - mask: {{ _cron.mask|yaml }}
    - cmd: {{ _cron.command|yaml_dquote }}
    - require_in:
      - file: incron/allowed-users
      - file: incron/denied-users
  {%- endif %}

{%- endfor %}
