{% from slspath ~ '/init.sls' import role %}

consul/service-directory:
  file.directory:
    - name: {{ (role.vars.service_dir)|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0700'
    - makedirs: true

consul/config-directory:
  file.directory:
    - name: {{ (role.vars.service_dir ~ '/config')|yaml_dquote }}
    - mode: '0750'
    - require:
      - file: consul/service-directory

consul/config:
  file.managed:
    - name: {{ (role.vars.service_dir ~ '/config/saltstack.json')|yaml_dquote }}
    - contents: {{ role.vars.config|json|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - makedirs: true
    - require_in:
      - file: consul/config-directory

consul/docker-volume:
  docker_volume.present:
    - name: {{ role.vars.docker_volume|yaml_dquote }}

consul/docker-container:
  docker_container.running:
    - name: 'consul'
    - image: {{ role.vars.docker_image|yaml_dquote }}
    - command: 'agent'
    - detach: true
    - network_mode: 'host'
    - restart_policy: 'always'
    - binds:
      - {{ (role.vars.service_dir ~ '/config:/consul/config')|yaml_dquote }}
      - {{ (role.vars.docker_volume ~ ':/consul/data')|yaml_dquote }}
    - require:
      - docker_volume: consul/docker-volume

  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: consul/config
    - require:
      - docker_container: consul/docker-container
