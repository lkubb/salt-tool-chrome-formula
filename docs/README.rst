.. _readme:

Google Chrome Formula
=====================

Manages Google Chrome browser in the user environment.

.. contents:: **Table of Contents**
   :depth: 1

Usage
-----
Applying ``tool_chrome`` will make sure Google Chrome is configured as specified.

Extensions Unlisted on Chrome Web Store
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Managing your browser with Enterprise Policies means it is easily possible to add extensions that are not listed on the official store (see `Local Extensions`_ for remarks on Windows). An example is found in `bypass-paywalls-clean`. You can easily amend the definitions in ``lookup:extensions_data``.

Local Extensions
~~~~~~~~~~~~~~~~
This formula provides a way to automatically install extensions from a local source. This `might not work on Windows <https://chromeenterprise.google/policies/#ExtensionSettings>`_ by default (ie without having joined an AD domain), at least for ``force_installed``. There `might be a workaround <https://hitco.at/blog/apply-edge-policies-for-non-domain-joined-devices/>`_.

Installing from local source means that extensions are **not updated automatically**, only when you are ready to do so yourself.

1. Generally, local extensions need to be found on the minion under the path specified by ``extensions:local:source``, named ``<extension_name>.crx``. E.g. for uBlock Origin on Linux, this would be ``/opt/chrome_extensions/ublock-origin.crx`` by default.

2. When requesting a local source for an extension with ``local: true``, you will need to specify its current version as ``local_version``. Since we are simulating a local repo, that is necessary to generate a sensible response for Chrome update requests.

3. When you update that file to a new version, remember to change the defined version accordingly and apply the states. On the next run, Chrome will be notified of the new version and update.

4. This formula uses a slightly modified TOFS pattern, as most of the ``tool`` formulae do. This is relevant when you provide the extension files for automatic syncing (recommended). They need to be found under one of the following paths (descending priority):

* ``salt://tool_chrome/extensions/<minion_id>/<extension_name>.crx``
* ``salt://tool_chrome/extensions/<os_family>/<extension_name>.crx``
* ``salt://tool_chrome/extensions/default/<extension_name>.crx``

You can disable the automatic syncing of local extensions, but beware that for manual management of your local repository, you need to manage the ``update`` file in there as well.


Configuration
-------------

This formula
~~~~~~~~~~~~
The general configuration structure is in line with all other formulae from the `tool` suite, for details see :ref:`toolsuite`. An example pillar is provided, see :ref:`pillar.example`. Note that you do not need to specify everything by pillar. Often, it's much easier and less resource-heavy to use the ``parameters/<grain>/<value>.yaml`` files for non-sensitive settings. The underlying logic is explained in :ref:`map.jinja`.

User-specific
^^^^^^^^^^^^^
The following shows an example of ``tool_chrome`` per-user configuration. If provided by pillar, namespace it to ``tool_global:users`` and/or ``tool_chrome:users``. For the ``parameters`` YAML file variant, it needs to be nested under a ``values`` parent key. The YAML files are expected to be found in

1. ``salt://tool_chrome/parameters/<grain>/<value>.yaml`` or
2. ``salt://tool_global/parameters/<grain>/<value>.yaml``.

.. code-block:: yaml

  user:

      # Force the usage of XDG directories for this user.
    xdg: true

      # Persist environment variables used by this formula for this
      # user to this file (will be appended to a file relative to $HOME)
    persistenv: '.config/zsh/zshenv'

      # Add runcom hooks specific to this formula to this file
      # for this user (will be appended to a file relative to $HOME)
    rchook: '.config/zsh/zshrc'

      # This user's configuration for this formula. Will be overridden by
      # user-specific configuration in `tool_chrome:users`.
      # Set this to `false` to disable configuration for this user.
    chrome:
        # Enable Chrome flags via Local State file. To find the correct syntax,
        # it is best to set them manually and look inside "Local State" (json)
        # `browser:enabled_labs_experiments`.
        # `chrome://version` will show an overview of enabled flags in the CLI variant
        # `chrome://flags` shows available flags and highlights
        # those different from default.
        # Mind that CLI switches will not be detected on that page.
      flags:
        - disable-accelerated-2d-canvas
        - enable-javascript-harmony
        - enable-webrtc-hide-local-ips-with-mdns@1

Formula-specific
^^^^^^^^^^^^^^^^

.. code-block:: yaml

  tool_chrome:

      # Which Chrome version to install:
      # stable, beta, dev, canary
    version: stable

    extensions:
        # List of extensions that should not be installed.
      absent:
        - tampermonkey
        # Defaults for extension installation settings
      defaults:
        installation_mode: normal_installed
        override_update_url: false
        update_url: https://clients2.google.com/service/update2/crx
        # add generated ExtensionSettings to forced policies
        # (necessary on MacOS at least)
      forced: true
        # This formula allows using extensions from the local file system.
        # Those extensions will not be updated automatically from the web.
      local:
          # When marking extensions as local, use this path on the minion to look for
          # `<extension>.crx` by default.
        source: /opt/chrome_extensions
          # When using local source, sync extensions automatically from the fileserver.
          # You will need to provide the extensions as
          # `tool_chrome/extensions/<tofs_grain>/<extension>.crx`
        sync: true
        # List of extensions that are to be installed. When using policies, can also
        # be specified there manually, but this provides convenience. See
        # `tool_chrome/parameters/defaults.yaml` for a list of available extensions under
        # `lookup:extension_data`. Of course, you can also specify your own on top.
      wanted:
        - bitwarden
          # If you want to override defaults, you can specify them
          # in a mapping like this:
        - ublock-origin:
            installation_mode: force_installed
            runtime_blocked_hosts:
              - '*://*.supersensitive.bank'
          # If you don't want an extension to be loaded from the Chrome Web Store
          # (or it's unlisted there), but rather from a local directory specified in
          # `extensions:defaults:local_source`, set local to true and make sure to
          # provide e.g. `metamask.crx` in there.
          # Since we simulate a local repo, you will need to tell Salt explicitly
          # which version you're providing and need to change the value when you want to
          # make Chrome aware the extension was updated on the next startup.
        - metamask:
            blocked_permissions:
              - geolocation
            local: true
            local_version: 10.8.1
            toolbar_pin: force_pinned

      # This is where you specify enterprise policies.
      # See https://chromeenterprise.google/policies/ for available settings.
    policies:
        # These policies are installed as forced, i.e. cannot be changed
        # by the user. On MacOS at least, this is where ExtensionSettings
        # has to be specified to take effect.
      forced:
        SSLErrorOverrideAllowed: false
        SSLVersionMin: tls1.2
        # These policies are installed as recommended, i.e. only provide
        # default values.
      recommended:
        AutofillCreditCardEnabled: false
        BlockThirdPartyCookies: true
        BookmarkBarEnabled: true
        BrowserNetworkTimeQueriesEnabled: false
        BrowserSignin: 0
        BuiltInDnsClientEnabled: false
        MetricsReportingEnabled: false
        PromotionalTabsEnabled: false
        SafeBrowsingExtendedReportingEnabled: false
        SearchSuggestEnabled: false
        ShowFullUrlsInAddressBar: true
        SyncDisabled: true
        UrlKeyedAnonymizedDataCollectionEnabled: false
        UserFeedbackAllowed: false

      # Default formula configuration for all users.
    defaults:
      flags: default value for all users

Development
-----------

Contributing to this repo
~~~~~~~~~~~~~~~~~~~~~~~~~

Commit messages
^^^^^^^^^^^^^^^

Commit message formatting is significant.

Please see `How to contribute <https://github.com/saltstack-formulas/.github/blob/master/CONTRIBUTING.rst>`_ for more details.

pre-commit
^^^^^^^^^^

`pre-commit <https://pre-commit.com/>`_ is configured for this formula, which you may optionally use to ease the steps involved in submitting your changes.
First install  the ``pre-commit`` package manager using the appropriate `method <https://pre-commit.com/#installation>`_, then run ``bin/install-hooks`` and
now ``pre-commit`` will run automatically on each ``git commit``.

.. code-block:: console

  $ bin/install-hooks
  pre-commit installed at .git/hooks/pre-commit
  pre-commit installed at .git/hooks/commit-msg

State documentation
~~~~~~~~~~~~~~~~~~~
There is a script that semi-autodocuments available states: ``bin/slsdoc``.

If a ``.sls`` file begins with a Jinja comment, it will dump that into the docs. It can be configured differently depending on the formula. See the script source code for details currently.

This means if you feel a state should be documented, make sure to write a comment explaining it.

Testing
~~~~~~~

Linux testing is done with ``kitchen-salt``.

Requirements
^^^^^^^^^^^^

* Ruby
* Docker

.. code-block:: bash

  $ gem install bundler
  $ bundle install
  $ bin/kitchen test [platform]

Where ``[platform]`` is the platform name defined in ``kitchen.yml``,
e.g. ``debian-9-2019-2-py3``.

``bin/kitchen converge``
^^^^^^^^^^^^^^^^^^^^^^^^

Creates the docker instance and runs the ``tool_chrome`` main state, ready for testing.

``bin/kitchen verify``
^^^^^^^^^^^^^^^^^^^^^^

Runs the ``inspec`` tests on the actual instance.

``bin/kitchen destroy``
^^^^^^^^^^^^^^^^^^^^^^^

Removes the docker instance.

``bin/kitchen test``
^^^^^^^^^^^^^^^^^^^^

Runs all of the stages above in one go: i.e. ``destroy`` + ``converge`` + ``verify`` + ``destroy``.

``bin/kitchen login``
^^^^^^^^^^^^^^^^^^^^^

Gives you SSH access to the instance for manual testing.

Todo
----
* allow syncing master_preferences (default settings for new profiles)
* automatically download external extensions, only request link to ``update.xml`` (~ as done in Chromium formula in some cases)
* `implement <https://www.reddit.com/r/uBlockOrigin/comments/qm0uxt/comment/hmpc5yl/?utm_source=share&utm_medium=web2x&context=3>`_ `extension-specific <https://github.com/uBlockOrigin/uBlock-issues/wiki/Deploying-uBlock-Origin>`_ `policies <https://dev.chromium.org/administrators/configuring-policy-for-extensions>`_

References
----------
* https://www.chromium.org/administrators/configuring-other-preferences
* https://www.chromium.org/administrators/linux-quick-start
* https://chromeenterprise.google/policies/
* https://support.google.com/chrome/a/answer/9037717
* https://chromium.googlesource.com/chromium/chromium/+/refs/heads/main/chrome/app/policy/policy_templates.json
* https://chromium.googlesource.com/chromium/chromium/+/refs/heads/main/chrome/app/policy/syntax_check_policy_template_json.py
* https://support.google.com/chrome/a/answer/187202?ref_topic=9023406&hl=en
* https://support.google.com/chrome/a/answer/2657289
* https://github.com/andrewpmontgomery/chrome-extension-store
* https://www.chromium.org/administrators/mac-quick-start
* https://support.google.com/chrome/a/answer/9867568?hl=en&ref_topic=9023246
* https://sunweavers.net/blog/node/135
* https://docs.google.com/document/d/1pT0ZSbGdrbGvuCsVD2jjxrw-GVz-80rMS2dgkkquhTY/

Further reading
---------------
* https://www.debugbear.com/chrome-extension-performance-lookup
