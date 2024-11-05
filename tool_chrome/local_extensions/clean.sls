# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as chrome with context %}


{%- if chrome.get("_local_extensions") and chrome.extensions.local.sync %}

Synced local Google Chrome extensions are absent:
  file.absent:
    - names:
{%-   for extension in chrome._local_extensions %}
      - {{ chrome.extensions.local.source | path_join(extension ~ ".crx") }}
{%-   endfor %}
      - {{ chrome.extensions.local.source | path_join("update") }}
{%- endif %}
