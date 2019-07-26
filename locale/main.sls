{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import locale %}

locale/packages:
  pkg.installed:
    - pkgs: {{ locale.packages|yaml }}

{%- for _locale in locale.present_locales %}
locale/present/{{ loop.index }}:
  locale.present:
    - name: {{ _locale|yaml_dquote }}
    - require:
      - pkg: locale/packages
    - require_in:
      - locale: locale/system
{%- endfor %}

{%- for _locale in locale.absent_locales %}
locale/absent/{{ loop.index }}:
  locale.absent:
    - name: {{ _locale|yaml_dquote }}
    - require:
      - pkg: locale/packages
    - require_in:
      - locale: locale/system
{%- endfor %}

{%- if locale.system_locale %}
locale/system:
  locale.system:
    - name: {{ locale.system_locale|yaml_dquote }}
{%- endif %}
