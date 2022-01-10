Ensure Debian repositories can be managed by tool-chrome:
  pkg.installed:
    - pkgs:
      - python-apt

# Debian only distributes Firefox ESR in stable repository, need unstable
Google Chrome apt repository is available:
  pkgrepo.managed:
    - humanname: Google Chrome
    - name: deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main
    - file: /etc/apt/sources.list.d/google-chrome.list
    - key_url: https://dl.google.com/linux/linux_signing_key.pub
