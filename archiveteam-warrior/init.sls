{% set role = salt['ss.role']('archiveteam-warrior') %}
{% import role.dependency('docker') as docker %}{% set docker = docker %}

include: {{ role.includes|yaml }}
