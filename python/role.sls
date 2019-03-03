{% from slspath ~ '/init.sls' import role %}

python/packages:
  pkg.installed:
    - pkgs: {{ role.vars.packages|yaml }}
