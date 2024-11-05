# vim: ft=sls

{#-
    This state will install the configured Google Chrome repository.
    This works for apt/dnf/yum/zypper-based distributions only by default.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as chrome with context %}

include:
{%- if chrome.lookup.pkg.manager in ["apt", "dnf", "yum", "zypper"] %}
  - {{ slsdotpath }}.install
{%- elif salt["state.sls_exists"](slsdotpath ~ "." ~ chrome.lookup.pkg.manager) %}
  - {{ slsdotpath }}.{{ chrome.lookup.pkg.manager }}
{%- else %}
  []
{%- endif %}
