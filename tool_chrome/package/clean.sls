# vim: ft=sls

{#-
    Removes the Google Chrome package.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as chrome with context %}

include:
  - {{ slsdotpath }}.repo.clean


{%- if grains.os == "Windows" %}

Google Chrome is removed:
  chocolatey.uninstalled:
    - name: {{ chrome._pkg.name }}
    - pre_versions: {{ chrome._pkg.pre }}
{%- else %}

Google Chrome is removed:
  pkg.removed:
    - name: {{ chrome._pkg.name }}
{%- endif %}
