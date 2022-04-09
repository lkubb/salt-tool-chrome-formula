.. _notes:

Notes
=====
General
~~~~~~~
- Chrome/Chromium somehow comply to XDG spec, but forcing it on MacOS would put cache into profile dir in XDG_CONFIG_HOME. Also dotfiles are not really a thing.
- Installation from local source is possible by adding `file:///absolute/path/*` to `ExtensionInstallSources` in **enforced** policies.
- Distinction between managed=forced and recommended:

  + Linux: /etc/opt/chrome/policies/{managed, recommended}
  + MacOS: (system) profile (plist in `/Library/Managed Preferences[/$USER]`) vs plist in `~/Library/Preferences`
  + Windows: `Google Chrome` vs `Google Chrome – Default Settings (users can override)`

- ExtensionSettings needs to be `minified JSON on Windows <https://support.google.com/chrome/a/answer/7532015>`_.

User Data Directories
~~~~~~~~~~~~~~~~~~~~~
(relative to user home)

.. code-block:: yaml

  Windows:
    stable: /AppData/Local/Google/Chrome/User Data
    beta: /AppData/Local/Google/Chrome Beta/User Data
    dev: /AppData/Local/Google/Chrome Dev/User Data
    canary: /AppData/Local/Google/Chrome SxS/User Data

  Darwin:
    stable: /Library/Application Support/Google/Chrome
    beta: /Library/Application Support/Google/Chrome Beta
    dev: /Library/Application Support/Google/Chrome Dev
    canary: /Library/Application Support/Google/Chrome Canary

  Linux:
    stable: /.config/google-chrome # actually XDG_CONFIG_HOME
    beta: /.config/google-chrome-beta
    dev: /.config/google-chrome-unstable
    canary: False # no canary for Linux atm
