{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import atwarrior %}

include:
  - docker

atwarrior/docker-container:
  docker_container.running:
    - name: 'archiveteam-warrior'
    - image: {{ atwarrior.docker_image|yaml_dquote }}
    - detach: true
    - restart_policy: 'always'
    - environment:
        DOWNLOADER: {{ atwarrior.warrior_name }}
        SELECTED_PROJECT: {{ atwarrior.warrior_project }}
        CONCURRENT_ITEMS: {{ atwarrior.warrior_concurrency }}
    - port_bindings:
      - {{ (atwarrior.warrior_port ~ ':8001/tcp')|yaml_dquote }}
