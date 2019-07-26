{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import interfaces %}

interfaces/packages:
  pkg.installed:
    - pkgs: {{ interfaces.packages|yaml }}

interfaces/udev-rules:
  file.managed:
    - name: {{ interfaces.udev_rules_path|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['udev-rules.j2'],
        lookup='udev-rules-config'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        interfaces: {{ interfaces|yaml }}
    - require:
      - pkg: interfaces/packages

  cmd.run:
    - name: 'udevadm trigger'
    - onchanges:
      - file: interfaces/udev-rules

interfaces/config:
  file.managed:
    - name: {{ interfaces.interfaces_path|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['interfaces.j2'],
        lookup='interfaces-config'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - template: 'jinja'
    - context:
        interfaces: {{ interfaces|yaml }}

interfaces/config-dir:
  file.directory:
    - name: {{ interfaces.interfaces_dir|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0755'
    - clean: True

{%- if not interfaces.single_config %}
{%- for _interface_name, _interface in interfaces.configs|dictsort %}
interfaces/device/{{ _interface_name }}:
  file.managed:
    - name: {{ (interfaces.interfaces_dir ~ '/' ~ _interface_name)|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['interface.j2'],
        lookup='interface-config'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - dir_mode: '0755'
    - makedirs: True
    - template: 'jinja'
    - context:
        interfaces: {{ interfaces|yaml }}
        interface_name: {{ _interface_name|yaml }}
        interface: {{ _interface|yaml }}
    - require:
      - cmd: interfaces/udev-rules
      - file: interfaces/config
    - require_in:
      - file: interfaces/config-dir
{%- endfor %}
{%- endif %}
