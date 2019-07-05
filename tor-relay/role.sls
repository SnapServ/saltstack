{% from slspath ~ '/init.sls' import role %}

tor-relay/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}

tor-relay/config:
  file.managed:
    - name: {{ role.vars.config_path|yaml_dquote }}
    - source: {{ role.tpl_path('torrc.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: {{ role.vars.service_user|yaml_dquote }}
    - group: {{ role.vars.service_group|yaml_dquote }}
    - mode: '0640'
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - pkg: tor-relay/packages

{% if grains['os_family'].lower() == 'debian' and grains['virtual'].lower() == 'lxc' %}
tor-relay/disable-apparmor:
  file.managed:
    - name: '/etc/systemd/system/tor@default.service.d/override.conf'
    - contents: |
        [Service]
        AppArmorProfile=
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - dir_mode: '0755'
    - makedirs: true
    - require:
      - pkg: tor-relay/packages

  module.run:
    - name: 'service.systemctl_reload'
    - onchanges:
      - file: tor-relay/disable-apparmor
    - require_in:
      - service: tor-relay/service
{% else %}
tor-relay/enable-apparmor:
  file.absent:
    - name: '/etc/systemd/system/tor@default.service.d/override.conf'
    - require:
      - pkg: tor-relay/packages

  module.run:
    - name: 'service.systemctl_reload'
    - onchanges:
      - file: tor-relay/enable-apparmor
    - require_in:
      - service: tor-relay/service
{% endif %}

tor-relay/service:
  service.running:
    - name: {{ role.vars.service|yaml_dquote }}
    - enable: true
    - reload: true
    - watch:
      - file: tor-relay/config
