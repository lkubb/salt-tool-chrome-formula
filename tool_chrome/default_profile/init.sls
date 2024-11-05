# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as chrome with context %}

include:
  - {{ sls_package_install }}


{%- for user in chrome.users %}

Google Chrome has been run once for user '{{ user.name }}':
  cmd.run:
    - name: |
        "{{ chrome._bin }}"
    - runas: {{ user.name }}
    - bg: true
    - timeout: 20
    - hide_output: true
    - require:
      - sls: {{ sls_package_install }}
    - creates:
      - {{ user._chrome.confdir | path_join("Default") }}

Google Chrome has generated the default profile for user '{{ user.name }}':
  file.exists:
    - name: {{ user._chrome.confdir | path_join("Default") }}
    - retry:
        attempts: 10
        interval: 1
    - require:
      - Google Chrome has been run once for user '{{ user.name }}'

Google Chrome is not running for user '{{ user.name }}':
  process.absent:
    - name: {{ salt["file.basename"](chrome._bin) }}
    - user: {{ user.name }}
    - onchanges:
      - Google Chrome has been run once for user '{{ user.name }}'
{%- endfor %}
