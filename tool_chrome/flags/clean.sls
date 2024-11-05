# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as chrome with context %}


{%- for user in chrome.users | selectattr("chrome.flags", "defined") %}

Google Chrome flags are inactive for user {{ user.name }}:
  file.serialize:
    - name: {{ user._chrome.confdir | path_join("Local State") }}
    - serializer: json
    - merge_if_exists: true
    - dataset: {{ {"browser": {"enabled_labs_experiments": []} } |  json }}
    - mode: '0600'
    - user: {{ user.name }}
    - group: {{ user.group }}
    - onlyif:
      - test -e '{{ user._chrome.confdir | path_join("Local State") }}'
{%- endfor %}
