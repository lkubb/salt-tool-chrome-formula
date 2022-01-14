{%- from 'tool-chrome/map.jinja' import chrome -%}

{%- if chrome.users | selectattr('chrome.flags', 'defined') | list %}
include:
  - .active
{%- endif %}
