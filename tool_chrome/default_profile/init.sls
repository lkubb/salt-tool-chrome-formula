# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as chrome with context %}

include:
  - {{ sls_package_install }}


{%- for user in chrome.users %}

Google Chrome has generated the default profile for user '{{ user.name }}':
  cmd.run:
    - name: |
        "{{ chrome._bin }}" &
        while [ ! -d '{{ user._chrome.confdir | path_join('Default') }}' ]; do
          sleep 1;
        done
        sleep 1
        killall "$(basename '{{ chrome._bin }}')"
    - runas: {{ user.name }}
    - require:
      - sls: {{ sls_package_install }}
    - unless:
      - test -d '{{ user._chrome.confdir | path_join('Default') }}'
{%- endfor %}
