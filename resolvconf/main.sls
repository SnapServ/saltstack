{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import resolvconf %}

resolvconf/config:
  file.managed:
    - name: {{ resolvconf.resolvconf_path|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['resolvconf.j2'],
        lookup='resolvconf-config'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        resolvconf: {{ resolvconf|yaml }}
