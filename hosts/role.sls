{% from slspath ~ '/init.sls' import role %}

{% if not (role.hostname and role.domain) %}
hosts/failure-1:
  test.fail_without_changes:
    - name: {{ 'Unable to determine host or domain name! (hostname={:s}, domain={:s})'
                .format(role.hostname, role.domain)|yaml_dquote }}
    - failhard: True
{% endif %}

{% if not (role.primary_address4 or role.primary_address6) %}
hosts/failure-2:
  test.fail_without_changes:
    - name: {{ 'Unable to determine primary network address! (v4={:s}, v6={:s})'
                .format(role.primary_address4, role.primary_address6)|yaml_dquote }}
    - failhard: True
{% endif %}

hosts/hostname:
  cmd.run:
    - name: {{ role.hostname_cmd_fmt.format(role.hostname)|yaml_dquote }}
    - unless: test {{ role.hostname|quote }} = "$(hostname)"

  file.managed:
    - name: {{ role.hostname_path|yaml_dquote }}
    - contents: {{ role.hostname|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - require:
      - cmd: hosts/hostname

hosts/config:
  file.managed:
    - name: {{ role.hosts_path|yaml_dquote }}
    - source: {{ ('salt://' ~ slspath ~ '/files/hosts.j2')|yaml_dquote }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        role: {{ role|yaml }}
    - require:
      - file: hosts/hostname
