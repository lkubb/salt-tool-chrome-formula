# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as chrome with context %}

{%- set require_local_sync = chrome.get('_local_extensions') | to_bool
                         and chrome.extensions.local.sync | to_bool %}

{%- if 'Windows' == grains.kernel or require_local_sync %}

include:
{%-   if require_local_sync %}
  - {{ tplroot }}.local_extensions
{%-   endif %}
{%-   if 'Windows' == grains.kernel %}
  - {{ slsdotpath }}.winadm
{%-   endif %}
{%- endif %}


{%- if chrome.get('_policies') %}
{%-   if 'Windows' == grains.kernel %}
{%-     if chrome._policies.get('forced') %}

Google Chrome forced policies are applied as Group Policy:
  lgpo.set:
    - computer_policy: {{ chrome._policies.forced | json }}
    - adml_language: {{ chrome.lookup.win_gpo.lang }}
    - watch_in:
      - Group policies are updated
    - require:
      - sls: {{ slsdotpath }}.winadm
{%-       if require_local_sync %}
      - sls: {{ tplroot }}.local_extensions
{%-       endif %}
{%-     endif %}

{%-     if chrome._policies.get('recommended') %}

Google Chrome recommended policies are applied as Group Policy:
  lgpo.set:
    - user_policy: {{ chrome._policies.recommended | json }}
    - adml_language: {{ chrome.lookup.win_gpo.lang }}
    - watch_in:
      - Group policies are updated
    - require:
      - sls: {{ slsdotpath }}.winadm
{%-       if require_local_sync %}
      - sls: {{ tplroot }}.local_extensions
{%-       endif %}
{%-     endif %}

Group policies are updated:
  cmd.wait:  # noqua 123
    - name: gpupdate /wait:0
    - watch: []

{%-   elif 'Darwin' == grains.kernel %}
{%-     if chrome._policies.get('forced') %}

Google Chrome forced policies are applied as profile:
  macprofile.installed:
    - name: salt.tool.com.google.Chrome
    - displayname: Chrome configuration (salt-tool)
    - description: Chrome default configuration managed by Salt state tool_chrome.policies.install
    - organization: salt.tool
    - removaldisallowed: false
    - ptype: com.google.Chrome
    - content:
      - {{ chrome._policies.forced | json }}
{%-       if require_local_sync %}
    - require:
      - sls: {{ tplroot }}.local_extensions
{%-       endif %}
{%-     endif %}

{%-     if chrome._policies.get('recommended') %}

Google Chrome recommended policies are applied as plist:
  file.serialize:
    - name: /Library/Preferences/com.google.Chrome.plist
    - serializer: plist
    - merge_if_exists: true
    - user: root
    - group: {{ chrome.lookup.rootgroup }}
    - mode: '0644'
    - dataset: {{ chrome._policies.recommended | json }}
{%-       if require_local_sync %}
    - require:
      - sls: {{ tplroot }}.local_extensions
{%-       endif %}

MacOS plist cache is updated for Chrome:
  cmd.run:
    - name: defaults read /Library/Preferences/com.google.Chrome.plist
    - onchanges:
      - Google Chrome recommended policies are applied as plist
{%-     endif %}

{%-   else %}
{%-     if chrome._policies.get('forced') %}

Google Chrome enforced policies are synced to json file:
  file.serialize:
    - name: /etc/opt/chrome/policies/managed/salt_tool_managed_policies.json
    - dataset: {{ chrome._policies.forced | json }}
    - serializer: json
    - makedirs: true
    - user: root
    - group: {{ chrome.lookup.rootgroup }}
    - mode: '0644'
{%-       if require_local_sync %}
    - require:
      - sls: {{ tplroot }}.local_extensions
{%-       endif %}
{%-     endif %}

{%-     if chrome._policies.get('recommended') %}

Google Chrome recommended policies are synced to json file:
  file.serialize:
    - name: /etc/opt/chrome/policies/recommended/salt_tool_recommended_policies.json
    - dataset: {{ chrome._policies.recommended | json }}
    - serializer: json
    - makedirs: true
    - user: root
    - group: {{ chrome.lookup.rootgroup }}
    - mode: '0644'
{%-       if require_local_sync %}
    - require:
      - sls: {{ tplroot }}.local_extensions
{%-       endif %}
{%-     endif %}
{%-   endif %}
{%- endif %}
