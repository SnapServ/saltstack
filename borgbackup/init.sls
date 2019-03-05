{% set role = salt['ss.role']('borgbackup') %}
{% import role.dependency('python') as python %}{% set python = python %}

include: {{ role.includes|yaml }}
