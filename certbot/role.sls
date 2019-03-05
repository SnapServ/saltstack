{% from slspath ~ '/init.sls' import role %}

certbot/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}
    {% if role.vars.package_repository %}
    - fromrepo: {{ role.vars.package_repository|yaml_dquote }}
    {% endif %}

certbot/service:
  service.enabled:
    - name: {{ role.vars.service|yaml_dquote }}
    - require:
      - pkg: certbot/packages

certbot/service-timer:
  service.running:
    - name: {{ role.vars.service_timer|yaml_dquote }}
    - enable: True
    - require:
      - service: certbot/service
