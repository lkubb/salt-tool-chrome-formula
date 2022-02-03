{%- from 'tool-chrome/map.jinja' import chrome -%}

include:
  - .synclocalexts
{%- if 'Windows' == grains.kernel %}
  - .winadm

Google Chrome forced policies are applied as Group Policy:
  lgpo.set:
    - computer_policy: {{ chrome._policies.forced | json }}
    - adml_language: {{ chrome.win_gpo_lang | default('en_US') }}
    - require:
      - sls: {{ slspath }}.winadm
      - sls: {{ slspath }}.synclocaladdons

Google Chrome recommended policies are applied as Group Policy:
  lgpo.set:
    - user_policy: {{ chrome._policies.recommended | json }}
    - adml_language: {{ chrome.win_gpo_lang | default('en_US') }}
    - require:
      - sls: {{ slspath }}.winadm
      - sls: {{ slspath }}.synclocaladdons

Group policies are updated:
  cmd.run:
    - name: gpupdate /wait:0
    - onchanges:
      - Google Chrome forced policies are applied as Group Policy
      - Google Chrome recommended policies are applied as Group Policy

{%- elif 'Darwin' == grains.kernel %}

Google Chrome forced policies are applied as profile:
  macprofile.installed:
    - name: salt.tool.com.google.Chrome
    - description: Chrome default configuration managed by Salt state tool-chrome.policies
    - organization: salt.tool
    - removaldisallowed: False
    - ptype: com.google.Chrome
    - content:
      - {{ chrome._policies.forced | json }}

Google Chrome recommended policies are applied as plist:
  file.serialize:
    - name: /Library/Preferences/com.google.Chrome.plist
    - serializer: plist
    - merge_if_exists: True
    - user: root
    - group: {{ salt['user.primary_group']('root') }}
    - mode: '0644'
    - dataset: {{ chrome._policies.recommended | json }}

MacOS plist cache is updated for Chrome:
  cmd.run:
    - name: defaults read /Library/Preferences/com.google.Chrome.plist
    - onchanges:
      - Google Chrome recommended policies are applied as plist

{%- else %}

Google Chrome enforced policies are synced to json file:
  file.serialize:
    - name: /etc/opt/chrome/policies/managed/salt_tool_managed_policies.json
    - dataset: {{ chrome._policies.enforced | json }}
    - serializer: json
    - makedirs: true
    - user: root
    - group: root
    - mode: '0644'

Google Chrome recommended policies are synced to json file:
  file.serialize:
    - name: /etc/opt/chrome/policies/recommended/salt_tool_recommended_policies.json
    - dataset: {{ chrome._policies.recommended | json }}
    - serializer: json
    - makedirs: true
    - user: root
    - group: root
    - mode: '0644'
{%- endif %}
