{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import account %}

{%- for _user_name, _user in account.users|dictsort %}

{#- Merge user settings with default settings #}
{%- set _user = salt['defaults.merge'](
  account.user_defaults, _user, in_place=False
) %}
{%- set _user_info = salt['user.info'](_user_name) %}

{#- Declare SSH keys for each account #}
{%- if _user.enabled and _user_info.home is defined %}
account/ssh-keys/{{ _user_name }}:
  file.managed:
    - name: {{ (_user_info.home ~ '/.ssh/authorized_keys')|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['ssh-keys.j2'],
        lookup='ssh-keys-config'
      ) }}
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
{%- endif %}

{%- endfor %}
