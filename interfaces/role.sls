{% from slspath ~ '/init.sls' import role %}

interfaces/packages:
  pkg.installed:
    - pkgs: {{ role.packages|yaml }}

interfaces/udev-rules:
  file.managed:
    - name: {{ role.udev_rules_path|yaml_dquote }}
    - source: {{ ('salt://' ~ slspath ~ '/files/udev-rules.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        role: {{ role|yaml }}
    - require:
      - pkg: interfaces/packages

  cmd.run:
    - name: 'udevadm trigger'
    - onchanges:
      - file: interfaces/udev-rules

interfaces/config:
  file.managed:
    - name: {{ role.interfaces_path|yaml_dquote }}
    - source: {{ ('salt://' ~ slspath ~ '/files/interfaces.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - template: 'jinja'
    - context:
        role: {{ role|yaml }}

interfaces/config-dir:
  file.directory:
    - name: {{ role.interfaces_dir|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0755'
    - clean: True

{% if not role.single_config %}
{% for _interface_name, _interface in role.configs|dictsort %}
interfaces/device/{{ _interface_name }}:
  file.managed:
    - name: {{ (role.interfaces_dir ~ '/' ~ _interface_name)|yaml_dquote }}
    - source: {{ ('salt://' ~ slspath ~ '/files/interface.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - dir_mode: '0755'
    - makedirs: True
    - template: 'jinja'
    - context:
        role: {{ role|yaml }}
        interface_name: {{ _interface_name|yaml }}
        interface: {{ _interface|yaml }}
    - require:
      - cmd: interfaces/udev-rules
      - file: interfaces/config
    - require_in:
      - file: interfaces/config-dir
{% endfor %}
{% endif %}
