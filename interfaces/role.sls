{% from slspath ~ '/init.sls' import role %}

interfaces/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}

interfaces/udev-rules:
  file.managed:
    - name: {{ role.vars.udev_rules_path|yaml_dquote }}
    - source: {{ role.tpl_path('udev-rules.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - pkg: interfaces/packages

  cmd.run:
    - name: 'udevadm trigger'
    - onchanges:
      - file: interfaces/udev-rules

interfaces/config:
  file.managed:
    - name: {{ role.vars.interfaces_path|yaml_dquote }}
    - source: {{ role.tpl_path('interfaces.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - template: 'jinja'
    - context:
        vars: {{ role.vars|yaml }}

interfaces/config-dir:
  file.directory:
    - name: {{ role.vars.interfaces_dir|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0755'
    - clean: True

{% if not role.vars.single_config %}
{% for _interface_name, _interface in role.vars.configs|dictsort %}
interfaces/device/{{ _interface_name }}:
  file.managed:
    - name: {{ (role.vars.interfaces_dir ~ '/' ~ _interface_name)|yaml_dquote }}
    - source: {{ role.tpl_path('interface.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - dir_mode: '0755'
    - makedirs: True
    - template: 'jinja'
    - context:
        vars: {{ role.vars|yaml }}
        interface_name: {{ _interface_name|yaml }}
        interface: {{ _interface|yaml }}
    - require:
      - cmd: interfaces/udev-rules
      - file: interfaces/config
    - require_in:
      - file: interfaces/config-dir
{% endfor %}
{% endif %}
