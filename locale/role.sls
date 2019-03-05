{% from slspath ~ '/init.sls' import role %}

locale/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}

{% for _locale in role.vars.present_locales %}
locale/present/{{ loop.index }}:
  locale.present:
    - name: {{ _locale|yaml_dquote }}
    - require:
      - pkg: locale/packages
    - require_in:
      - locale: locale/system
{% endfor %}

{% for _locale in role.vars.absent_locales %}
locale/absent/{{ loop.index }}:
  locale.absent:
    - name: {{ _locale|yaml_dquote }}
    - require:
      - pkg: locale/packages
    - require_in:
      - locale: locale/system
{% endfor %}

{% if role.vars.system_locale %}
locale/system:
  locale.system:
    - name: {{ role.vars.system_locale|yaml_dquote }}
{% endif %}
