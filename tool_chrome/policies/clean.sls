# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as chrome with context %}

{%- set require_local_sync = chrome.get('_local_extensions') | to_bool
                         and chrome.extensions.local.sync | to_bool %}

{%- if 'Windows' == grains.kernel or require_local_sync %}
include:
{%-   if require_local_sync %}
  - {{ tplroot }}.local_addons.clean
{%-   endif %}
{%-   if 'Windows' == grains.kernel %}
  - {{ slsdotpath }}.winadm.clean
{%-   endif %}
{%- endif %}

{%- if 'Windows' == grains.kernel %}

Google Chrome forced policies are removed from Group Policy:
  lgpo.set:
    - computer_policy: {}
    - adml_language: {{ chrome.lookup.win_gpo.lang }}
    # this might very well not be allowed @FIXME
    - require_in:
      - sls: {{ slsdotpath }}.winadm.clean

Google Chrome recommended policies are removed from Group Policy:
  lgpo.set:
    - user_policy: {}
    - adml_language: {{ chrome.lookup.win_gpo.lang }}
    # this might very well not be allowed @FIXME
    - require_in:
      - sls: {{ slsdotpath }}.winadm.clean

Group policies are updated:
  cmd.run:
    - name: gpupdate /wait:0
    - onchanges:
      - Google Chrome forced policies are removed from Group Policy
      - Google Chrome recommended policies are removed from Group Policy

{%- elif 'Darwin' == grains.kernel %}

Google Chrome forced policy profile cannot be silently removed:
  test.show_notification:
    - text: >
        Salt cannot silently remove an installed system profile.
        You will need to do that manually. See
            System Preferences > Profiles

Google Chrome recommended policies are removed:
  file.absent:
    - name: /Library/Preferences/com.google.Chrome.plist
{%-   if require_local_sync %}
    - require:
      - sls: {{ tplroot }}.local_extensions.clean
{%-   endif %}

MacOS plist cache is updated for Chrome:
  cmd.run:
    - name: defaults read /Library/Preferences/com.google.Chrome.plist
    - onchanges:
      - Google Chrome recommended policies are removed

{%- else %}

Google Chrome enforced policies are removed:
  file.absent:
    - name: /etc/opt/chrome/policies/managed/salt_tool_managed_policies.json

Google Chrome recommended policies are removed:
  file.absent:
    - name: /etc/opt/chrome/policies/recommended/salt_tool_recommended_policies.json
{%- endif %}
