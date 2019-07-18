{% from slspath ~ '/init.sls' import role %}

archiveteam-warrior/docker-container:
  docker_container.running:
    - name: 'archiveteam-warrior'
    - image: {{ role.vars.docker_image|yaml_dquote }}
    - detach: true
    - restart_policy: 'always'
    - environment:
        DOWNLOADER: {{ role.vars.warrior_name }}
        SELECTED_PROJECT: {{ role.vars.warrior_project }}
        CONCURRENT_ITEMS: {{ role.vars.warrior_concurrency }}
    - port_bindings:
      - {{ (role.vars.warrior_port ~ ':8001/tcp')|yaml_dquote }}
