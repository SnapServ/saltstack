{% set role = salt['ss.role']('consul') %}
{% import role.dependency('docker') as docker %}{% set docker = docker %}

include: {{ role.includes|yaml }}
