{%- from 'tool-chrome/map.jinja' import chrome -%}

include:
  - .package
{%- if chrome.get('_policies') %}
  - .policies
{%- endif %}
