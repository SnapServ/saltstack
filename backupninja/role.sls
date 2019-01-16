{% set role = salt['ssx.role_data']('backupninja') %}

backupninja/packages:
  pkg.installed:
    - pkgs: {{ (role.packages + role.handler_packages)|yaml }}

backupninja/config:
  file.managed:
    - name: {{ role.config_path|yaml_dquote }}
    - source: {{ ('salt://' ~ slspath ~ '/files/backupninja.conf.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0640'
    - context:
        role: {{ role|yaml }}
    - require:
      - pkg: backupninja/packages

backupninja/job-dir:
  file.directory:
    - name: {{ role.config_dir|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0750'
    - clean: True
    - require:
      - pkg: backupninja/packages

{% for _job_name, _job in role.jobs|dictsort %}
backupninja/job/{{ _job_name }}:
  file.managed:
    - name: {{ (role.config_dir ~ '/' ~ _job_name)|yaml_dquote }}
    - source: {{ ('salt://' ~ slspath ~ '/files/job.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0640'
    - dir_mode: '0750'
    - makedirs: True
    - context:
        role: {{ role|yaml }}
        job: {{ _job|yaml }}
    - require:
      - pkg: backupninja/packages
    - require_in:
      - file: backupninja/job-dir
{% endfor %}
