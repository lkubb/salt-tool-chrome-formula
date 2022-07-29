# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as chrome with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}


{%- if chrome.get('_local_extensions') and chrome.extensions.local.sync %}

Requested local Google Chrome extensions are synced:
  file.managed:
    - names:
{%-   for extension in chrome._local_extensions %}
      - {{ chrome.extensions.local.source | path_join(extension ~ '.crx') }}:
        - source: {{ files_switch([extension ~ '.crx'],
                              lookup='Requested local Google Chrome extensions are synced',
                              indent_width=10,
                              override_root=tplroot ~ '/extensions')
                  }}
{%-   endfor %}
    - mode: '0644'
    - user: root
    - group: {{ chrome.lookup.rootgroup }}
    - makedirs: true

Local Google Chrome extension update file contains current versions:
  file.managed:
    - name: {{ chrome.extensions.local.source | path_join('update') }}
    - source: {{ files_switch(['update'],
                          lookup='Local Google Chrome extension update file contains current versions')
              }}
    - template: jinja
    - context:
        local_source: {{ chrome.extensions.local.source }}
        extensions: {{ chrome._local_extensions | json }}
    - mode: '0644'
    - user: root
    - group: {{ chrome.lookup.rootgroup }}
    - require:
      - Requested local Google Chrome extensions are synced
{%- endif %}
