{%- from 'tool-chrome/map.jinja' import chrome -%}

{%- if chrome.get('_local_extensions') and chrome.get('ext_local_source_sync', True) %}
Requested local Google Chrome extensions are synced:
  file.managed:
    - names:
  {%- for extension in chrome._local_extensions %}
      - {{ chrome.ext_local_source}}/{{ extension }}.crx:
        - source: salt://tool-chrome/files/extensions/{{ extension }}.crx
  {%- endfor %}
    - mode: '0644'
    - user: root
    - group: {{ salt['user.primary_group']('root') }}
    - makedirs: true

Local Google Chrome extension update file contains current versions:
  file.managed:
    - name: {{ chrome.ext_local_source}}/update
    - source: salt://tool-chrome/policies/files/update
    - template: jinja
    - context:
        local_source: {{ chrome.ext_local_source }}
        extensions: {{ chrome._local_extensions | json }}
    - user: root
    - group: {{ salt['user.primary_group']('root') }}
    - mode: '0644'
{%- endif %}
