{%- from 'tool-chrome/map.jinja' import chrome -%}

include:
  - .package
{%- if chrome.users | selectattr('chrome.flags', 'defined') | list %}
  - .flags
{%- endif %}
{%- if chrome.get('_policies') %}
  - .policies
{%- endif %}
