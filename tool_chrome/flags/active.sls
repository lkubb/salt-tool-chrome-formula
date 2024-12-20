# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as chrome with context %}

include:
  - {{ tplroot }}.default_profile


{%- for user in chrome.users | selectattr("chrome.flags", "defined") %}

Google Chrome flags are active for user {{ user.name }}:
  file.serialize:
    - name: {{ user._chrome.confdir | path_join("Local State") }}
    - serializer: json
    - merge_if_exists: true
    - dataset: {{ {"browser": {"enabled_labs_experiments": user.chrome.flags } } |  json }}
    - makedirs: true
    - mode: '0600'
    - dir_mode: '0700'
    - user: {{ user.name }}
    - group: {{ user.group }}
    - require:
      # Flags will not be accepted if the profile was not generated by Chrome first
      - Google Chrome has generated the default profile for user '{{ user.name }}'
{%- endfor %}
