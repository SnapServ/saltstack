{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import nginx %}
{%- from stdlib.formula_macros(tpldir) import nginx_virtualhost %}

include:
  - .global

nginx/vhosts-dir:
  file.directory:
    - name: {{ nginx.vhosts_dir|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0755'
    - clean:  True
    - require:
      - pkg: nginx/packages

{% for _vhost_name, _vhost in nginx.vhosts|dictsort %}
  {{- nginx_virtualhost(_vhost_name, **_vhost) -}}
{% endfor %}
