{% from slspath ~ '/init.sls' import role %}

{% for _user_name, _user in role.vars.users|dictsort %}
{% set _user = salt['ss.merge_recursive'](role.vars.user_defaults, _user) %}
{% set _user_info = salt['user.info'](_user_name) %}

{% if _user.enabled and _user_info.home is defined %}
account/sshkeys/{{ _user_name }}:
  file.managed:
    - name: {{ (_user_info.home ~ '/.ssh/authorized_keys')|yaml_dquote }}
    - source: {{ role.tpl_path('sshkeys.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: {{ _user_name|yaml_dquote }}
    - group: {{ _user_info.gid|yaml_encode }}
    - mode: '0600'
    - dir_mode: '0700'
    - makedirs: True
    - context:
        user: {{ _user|yaml }}
    - require:
      - user: account/user/{{ _user_name }}
{% endif %}

{% endfor %}
