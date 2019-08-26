{%- import 'stdlib.jinja' as stdlib %}
{%- from stdlib.formula_sls(tpldir) import hosts %}

{%- set _hostname = hosts.hostname or grains['host'] %}
{%- set _domain = hosts.domain or grains['domain'] %}
{%- set _primary_address4 = hosts.primary_address4 or salt['network.ip_addrs'](type='public')|first|default(none) %}
{%- set _primary_address6 = hosts.primary_address6 or salt['network.ip_addrs6'](cidr='2000::/3')|first|default(none) %}

{{- stdlib.ensure_var('hostname', _hostname) }}
{{- stdlib.ensure_var('domain', _domain) }}
{{- stdlib.ensure_var(
  'primary_address4 or primary_address6',
  _primary_address4 or _primary_address6
) }}

hosts/hostname:
  cmd.run:
    - name: {{ hosts.hostname_cmd_fmt.format(_hostname)|yaml_dquote }}
    - unless: test {{ _hostname|quote }} = "$(hostname)"

  file.managed:
    - name: {{ hosts.hostname_path|yaml_dquote }}
    - contents: {{ _hostname|yaml_dquote }}
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - require:
      - cmd: hosts/hostname

hosts/config:
  file.managed:
    - name: {{ hosts.hosts_path|yaml_dquote }}
    - source: {{ stdlib.formula_tofs(tpldir,
        source_files=['hosts.j2'],
        lookup='hosts-config'
      ) }}
    - template: 'jinja'
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - context:
        hostname: {{ _hostname|yaml_dquote }}
        domain: {{ _domain|yaml_dquote }}
        primary_address4: {{ _primary_address4|yaml_dquote }}
        primary_address6: {{ _primary_address6|yaml_dquote }}
    - require:
      - file: hosts/hostname
