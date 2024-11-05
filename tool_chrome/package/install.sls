# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as chrome with context %}

include:
  - {{ slsdotpath }}.repo


{%- if grains.os == "Windows" %}

Google Chrome is installed:
  chocolatey.installed:
    - name: {{ chrome._pkg.name }}
    - pre_versions: {{ chrome._pkg.pre }}
{%- else %}

Google Chrome is installed:
  pkg.installed:
    - name: {{ chrome._pkg.name }}
{%- endif %}

Google Chrome setup is completed:
  test.nop:
    - name: Hooray, Google Chrome setup has finished.
    - require:
      - Google Chrome is installed
