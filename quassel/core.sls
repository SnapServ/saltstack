{% from slspath ~ '/init.sls' import role %}

quassel/core/packages:
  pkg.installed:
    - pkgs: {{ role.vars.core.packages|yaml }}
    {% if 'packages_fromrepo' in role.vars %}
    - fromrepo: {{ role.vars.packages_fromrepo }}
    {% endif %}

quassel/core/deploy-cert-script:
  file.managed:
    - name: {{ (role.vars.core.data_dir ~ '/deploy-cert.sh')|yaml_dquote }}
    - source: {{ role.tpl_path('deploy-cert.sh.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0755'
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - pkg: quassel/core/packages

{% if grains['os_family'].lower() == 'debian' %}
quassel/core/support-service-reload:
  file.managed:
    - name: '/etc/systemd/system/quasselcore.service.d/override.conf'
    - contents: |
        [Service]
        ExecReload=/bin/kill -s HUP $MAINPID
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - dir_mode: '0755'
    - makedirs: true
    - require:
      - pkg: quassel/core/packages

  module.run:
    - name: 'service.systemctl_reload'
    - onchanges:
      - file: quassel/core/support-service-reload
    - require_in:
      - service: quassel/core/service
{% endif %}

quassel/core/service:
  service.running:
    - name: {{ role.vars.core.service|yaml_dquote }}
    - enable: true
    - reload: true
    - require:
      - pkg: quassel/core/packages
