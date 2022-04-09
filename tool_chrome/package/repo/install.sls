# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as chrome with context %}

{%- if grains['os'] in ['Debian', 'Ubuntu'] %}

Ensure Google Chrome APT repository can be managed:
  pkg.installed:
    - pkgs:
      - python-apt                    # required by Salt
{%-   if 'Ubuntu' == grains['os'] %}
      - python-software-properties    # to better support PPA repositories
{%-   endif %}
{%- endif %}

{%- for reponame in chrome.lookup.pkg.enablerepo %}

Google Chrome {{ repo }} repository is available:
  pkgrepo.managed:
{%-   for conf, val in chrome.lookup.pkg.repos[reponame].items() %}
    - {{ conf }}: {{ val }}
{%-   endfor %}
{%-   if chrome.lookup.pkg.manager in ['dnf', 'yum', 'zypper'] %}
    - enabled: 1
{%-   endif %}
    - require_in:
      - Google Chrome is installed
{%- endfor %}

{%- for reponame, repodata in chrome.lookup.pkg.repos.items() %}

{%-   if reponame not in chrome.lookup.pkg.enablerepo %}
Google Chrome {{ reponame }} repository is disabled:
  pkgrepo.absent:
{%-     for conf in ['name', 'ppa', 'ppa_auth', 'keyid', 'keyid_ppa', 'copr'] %}
{%-       if conf in repodata %}
    - {{ conf }}: {{ repodata[conf] }}
{%-       endif %}
{%-     endfor %}
    - require_in:
      - Google Chrome is installed
{%-   endif %}
{%- endfor %}
