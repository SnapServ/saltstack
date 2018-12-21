{% set role = salt['ssx.role_data']('locale') %}

locale/packages:
  pkg.installed:
    - pkgs: {{ role.packages|yaml }}

{% for _locale in role.present_locales %}
locale/present/{{ loop.index }}:
  locale.present:
    - name: {{ _locale|yaml_dquote }}
    - require:
      - pkg: locale/packages
    - require_in:
      - locale: locale/system
{% endfor %}

{% for _locale in role.absent_locales %}
locale/absent/{{ loop.index }}:
  locale.absent:
    - name: {{ _locale|yaml_dquote }}
    - require:
      - pkg: locale/packages
    - require_in:
      - locale: locale/system
{% endfor %}

{% if role.system_locale %}
locale/system:
  locale.system:
    - name: {{ role.system_locale|yaml_dquote }}
{% endif %}
