{% from slspath ~ '/init.sls' import role %}

certbot/packages:
  pkg.installed:
    - pkgs: {{ role.packages|yaml }}
    {% if role.package_repository %}
    - fromrepo: {{ role.package_repository|yaml_dquote }}
    {% endif %}

certbot/service:
  service.enabled:
    - name: {{ role.service|yaml_dquote }}
    - require:
      - pkg: certbot/packages

certbot/service-timer:
  service.running:
    - name: {{ role.service_timer|yaml_dquote }}
    - enable: True
    - require:
      - service: certbot/service
