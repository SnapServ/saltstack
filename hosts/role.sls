{% from slspath ~ '/init.sls' import role %}

{% if not (role.vars.hostname and role.vars.domain) %}
hosts/failure-1:
  test.fail_without_changes:
    - name: {{ 'Unable to determine host or domain name! (hostname={:s}, domain={:s})'
                .format(role.vars.hostname, role.vars.domain)|yaml_dquote }}
    - failhard: True
{% endif %}

{% if not (role.vars.primary_address4 or role.vars.primary_address6) %}
hosts/failure-2:
  test.fail_without_changes:
    - name: {{ 'Unable to determine primary network address! (v4={:s}, v6={:s})'
                .format(role.vars.primary_address4, role.vars.primary_address6)|yaml_dquote }}
    - failhard: True
{% endif %}

hosts/hostname:
  cmd.run:
    - name: {{ role.vars.hostname_cmd_fmt.format(role.vars.hostname)|yaml_dquote }}
    - unless: test {{ role.vars.hostname|quote }} = "$(hostname)"

  file.managed:
    - name: {{ role.vars.hostname_path|yaml_dquote }}
    - contents: {{ role.vars.hostname|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - require:
      - cmd: hosts/hostname

hosts/config:
  file.managed:
    - name: {{ role.vars.hosts_path|yaml_dquote }}
    - source: {{ role.tpl_path('hosts.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        vars: {{ role.vars|yaml }}
    - require:
      - file: hosts/hostname
