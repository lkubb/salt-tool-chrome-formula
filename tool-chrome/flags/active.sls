{%- from 'tool-chrome/map.jinja' import chrome -%}

{%- for user in chrome.users | selectattr('chrome.flags', 'defined') | list %}

# Flags will not be accepted if the profile was not generated by Chrome first
Google Chrome has generated the default profile for user {{ user.name }}:
  cmd.run:
    - name: |
        "{{ chrome._bin }}" &
        while [ ! -d '{{ user._chrome.confdir }}/Default' ]; do
          sleep 1;
        done
        sleep 1
        killall "$(basename '{{ chrome._bin }}')"
    - runas: {{ user.name }}
    - unless:
      - test -d {{ user._chrome.confdir }}/Default

Google Chrome flags are active for user {{ user.name }}:
  file.serialize:
    - name: {{ user._chrome.confdir }}/Local State
    - serializer: json
    - merge_if_exists: True
    - dataset: {{ {'browser': {'enabled_labs_experiments': user.chrome.flags}} |  json }}
    - makedirs: true
    - mode: '0600'
    - dir_mode: '0700'
    - user: {{ user.name }}
    - group: {{ user.group }}
{%- endfor %}