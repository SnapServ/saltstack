{% from slspath ~ '/init.sls' import role %}
{% import 'nginx/macros.sls' as nginx %}

include:
  - .global

nginx/vhosts-dir:
  file.directory:
    - name: {{ role.vars.vhosts_dir|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0755'
    - clean:  True
    - require:
      - pkg: nginx/packages

{% for _vhost_name, _vhost in role.vars.vhosts|dictsort %}
  {{- nginx.declare_vhost(_vhost_name, _vhost) -}}
{% endfor %}
