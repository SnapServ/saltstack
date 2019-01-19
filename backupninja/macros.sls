{% set role = salt['custom.role_data']('backupninja') %}

{% macro declare_job(_name, _options) %}
backupninja/job/{{ _name }}:
  file.managed:
    - name: {{ (role.config_dir ~ '/' ~ _name)|yaml_dquote }}
    - source: {{ ('salt://backupninja/files/job.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0640'
    - dir_mode: '0750'
    - makedirs: True
    - context:
        role: {{ role|yaml }}
        job: {{ _options|yaml }}
    - require:
      - pkg: backupninja/packages
    - require_in:
      - file: backupninja/job-dir
{% endmacro %}
