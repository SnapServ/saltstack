{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import quassel %}

quassel/core/packages:
  pkg.installed:
    - pkgs: {{ quassel.core.packages|yaml }}
    {% if 'packages_fromrepo' in quassel %}
    - fromrepo: {{ quassel.packages_fromrepo }}
    {% endif %}

quassel/core/deploy-cert-script:
  file.managed:
    - name: {{ (quassel.core.data_dir ~ '/deploy-cert.sh')|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['deploy-cert.sh.j2'],
        lookup='deploy-cert-script'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0755'
    - context:
        quassel: {{ quassel|yaml }}
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
    - name: {{ quassel.core.service|yaml_dquote }}
    - enable: true
    - reload: true
    - require:
      - pkg: quassel/core/packages
