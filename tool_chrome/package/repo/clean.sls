# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as chrome with context %}


{%- if chrome.lookup.pkg.manager not in ['apt', 'dnf', 'yum', 'zypper'] %}
{%-   if salt['state.sls_exists'](slsdotpath ~ '.' ~ chrome.lookup.pkg.manager ~ '.clean') %}

include:
  - {{ slsdotpath ~ '.' ~ chrome.lookup.pkg.manager ~ '.clean' }}
{%-   endif %}

{%- else %}


{%-   for reponame, repodata in chrome.lookup.pkg.repos.items() %}

Google Chrome {{ reponame }} repository is absent:
  pkgrepo.absent:
{%-     for conf in ['name', 'ppa', 'ppa_auth', 'keyid', 'keyid_ppa', 'copr'] %}
{%-       if conf in repodata %}
    - {{ conf }}: {{ repodata[conf] }}
{%-       endif %}
{%-     endfor %}
{%-   endfor %}
{%- endif %}
