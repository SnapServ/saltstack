{% from slspath ~ '/../init.sls' import role, python %}

{% for _retention_schedule_name, _retention_schedule in role.vars.retention_schedules|dictsort %}
{% set _retain_params = salt['ss.dict_strip_none']({
  'most_recent': _retention_schedule.most_recent|default(none),
  'first_of_hour': _retention_schedule.first_of_hour|default(none),
  'first_of_day': _retention_schedule.first_of_day|default(none),
  'first_of_week': _retention_schedule.first_of_week|default(none),
  'first_of_month': _retention_schedule.first_of_month|default(none),
  'first_of_year': _retention_schedule.first_of_year|default(none),
}) %}

borgbackup/tasks/retention-schedules/{{ _retention_schedule_name }}:
  file.retention_schedule:
    - name: {{ _retention_schedule.path|yaml_dquote }}
    - strptime_format: {{ _retention_schedule.pattern|default(none)|yaml_encode }}
    - retain: {{ _retain_params|yaml }}
{% endfor %}
