{%- from 'tool-chrome/map.jinja' import chrome -%}

{%- set pkg = salt['match.filter_by']({
  'beta': 'homebrew/cask-versions/google-chrome-beta',
  'dev': 'homebrew/cask-versions/google-chrome-dev',
  'canary': 'homebrew/cask-versions/google-chrome-canary',
  'stable': 'homebrew/cask/google-chrome',
  }, minion_id=chrome.version) -%}

Google Chrome is installed:
{# Homebrew always installs latest, mac_brew_pkg does not support upgrading a single package #}
  pkg.installed:
    - name: {{ pkg }}

Google Chrome setup is completed:
  test.nop:
    - name: Google Chrome setup has finished, hooray.
    - require:
      - pkg: {{ pkg }}
