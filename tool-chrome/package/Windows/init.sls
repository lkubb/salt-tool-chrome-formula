{%- from 'tool-chrome/map.jinja' import chrome -%}

{#- prereleases need --pre flag on Windows -#}
{%- set pkg = salt['match.filter_by']({
  'beta': {
    'name': 'googlechromebeta',
    'pre': True,
  },
  'dev': {
    'name': 'googlechrome.dev',
    'pre': False,
  },
  'canary': {
    'name': 'googlechrome.canary',
    'pre': False,
  },
  'stable': {
    'name': 'googlechrome',
    'pre': False
  }}, minion_id=chrome.version) -%}


Google Chrome is installed:
  chocolatey.installed:
    - name: {{ pkg.name }}
    - pre_versions: {{ pkg.pre }}

Google Chrome setup is completed:
  test.nop:
    - name: Google Chrome setup has finished, hooray.
    - require:
      - chocolatey: {{ pkg.name }}
