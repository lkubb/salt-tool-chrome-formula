{%- from 'tool-chrome/map.jinja' import chrome -%}

{%- set pkg = salt['match.filter_by']({
  'stable': 'google-chrome-stable',
  'dev': 'google-chrome-dev',
  'beta': 'google-chrome-beta'
  }, minion_id=chrome.version) -%}

include:
  - .repo

Google Chrome is installed:
  pkg.installed:
    - name: {{ pkg }}
    - refresh: true

Google Chrome setup is completed:
  test.nop:
    - name: Google Chrome setup has finished, hooray.
    - require:
      - pkg: {{ pkg }}
