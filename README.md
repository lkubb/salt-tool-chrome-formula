# Google Chrome Formula
Sets up and configures Google Chrome.

## Usage
Applying `tool-chrome` will make sure Google Chrome browser is configured as specified.

### Extensions Unlisted on Chrome Web Store
Managing your browser with Enterprise Policies means it is easily possible to add extensions that are not listed on the official store (see [Local Extensions](#local-extensions) for remarks on Windows). An example is found in `tool-chrome/policies/extensions/bypass-paywalls-clean.yml`. Create your own file that's mapped to `tool-chrome/policies/extensions/<name>.yml` and add it to the pillar extensions list.

### Local Extensions
This formula provides a way to automatically install extensions from a local source. This [might not work on Windows](https://chromeenterprise.google/policies/#ExtensionSettings) by default (ie without having joined an AD domain), at least for `force_installed`. There [might be a workaround](https://hitco.at/blog/apply-edge-policies-for-non-domain-joined-devices/).

Installing from local source means that extensions are **not updated automatically**, only when you are ready to do so yourself.

1. Generally, you need to define `ext_local_source`, which is the directory the local extensions should live in.
2. Then specify the extension's version in your pillar. That is necessary to generate a sensible response for Chrome update requests. The extension has to be available from `tool-chrome/files/extensions/<name>.crx`.
3. When you update that file to a new version, remember to change the pillar version definition accordingly and apply the states. On the next run, Chrome will be notified of the new version and update.

In the future, I want to automate 2/3 in this formula.

## Configuration
### Pillar
#### General `tool` architecture
Since installing user environments is not the primary use case for saltstack, the architecture is currently a bit awkward. All `tool` formulas assume running as root. There are three scopes of configuration:
1. per-user `tool`-specific
  > e.g. generally force usage of XDG dirs in `tool` formulas for this user
2. per-user formula-specific
  > e.g. setup this tool with the following configuration values for this user
3. global formula-specific (All formulas will accept `defaults` for `users:username:formula` default values in this scope as well.)
  > e.g. setup system-wide configuration files like this

**3** goes into `tool:formula` (e.g. `tool:git`). Both user scopes (**1**+**2**) are mixed per user in `users`. `users` can be defined in `tool:users` and/or `tool:formula:users`, the latter taking precedence. (**1**) is namespaced directly under `username`, (**2**) is namespaced under `username: {formula: {}}`.

```yaml
tool:
######### user-scope 1+2 #########
  users:                         #
    username:                    #
      xdg: true                  #
      dotconfig: true            #
      formula:                   #
        config: value            #
####### user-scope 1+2 end #######
  formula:
    formulaspecificstuff:
      conf: val
    defaults:
      yetanotherconfig: somevalue
######### user-scope 1+2 #########
    users:                       #
      username:                  #
        xdg: false               #
        formula:                 #
          otherconfig: otherval  #
####### user-scope 1+2 end #######
```

#### User-specific
The following shows an example of `tool-chrome` pillar configuration. Namespace it to `tool:users` and/or `tool:chrome:users`.
```yaml
user:
  chrome:
    flags:    # Enable Chrome flags via Local State file. To find the correct syntax, it is best to set them
              # and look inside "Local State" (json) browser:enabled_labs_experiments.
              # chrome://version will show an overview of enabled flags in the cli version
              # chrome://flags shows available flags and highlights those different from default
              # mind that cli switches will not be detected on that page
      - disable-accelerated-2d-canvas
      - enable-javascript-harmony
      - enable-webrtc-hide-local-ips-with-mdns@1
```

#### Formula-specific
```yaml
tool:
  chrome:
    version: stable                        # stable, beta, dev, canary. defaults to stable
    # When using policies.json on Linux, there are two global policy directories, therefore these
    # settings have to be global there. User-specific settings with policies are possible on MacOS
    # afaik where policies are installed via a profile.
    #################################################################################################
    # provide default values for ExtensionSettings
    # see https://support.google.com/chrome/a/answer/9867568?hl=en&ref_topic=9023246
    ext_defaults:
      installation_mode: normal_installed # When not specified, use this extension installation mode by default.
      # Setting update_url to something different than specified in the extension's manifest.json
      # and enabling override of update url will cause even update requests (not just installation)
      # to be routed there instead of the official source. For local extensions, this is set automatically.
      override_update_url: False
      # If you want to update from another repo by default, specify it here.
      # For local extensions, this is set automatically.
      update_url: https://clients2.google.com/service/update2/crx 
    # This formula allows using extensions from the local file system.
    # Those extensions will not be updated automatically from the web. Since we simulate a local repo,
    # you will need to tell salt explicitly which version you're providing and need to change
    # the setting when you want to make Chrome aware the extension was updated on the next startup.
    ext_local_source: /some/path # when marking extensions as local, use this path to look for extension.crx by default
    ext_local_source_sync: true  # when using local source, sync extensions from salt://tool-chrome/files/extensions (you should leave that on, unless you know what you're doing)
    ext_forced: false            # add parsed extension config to forced policies
    # List of extensions that are to be installed. When using policies, can also be specified there
    # manually, but this provides convenience. see tool-chrome/policies/extensions for list of
    # available extensions
    extensions:
      - bitwarden
      # If you don't want the default extension settings for your policy, you can specify them
      # in a mapping like this:
      - ublock-origin:
          installation_mode: force_installed
          runtime_blocked_hosts:
            - '*://*.supersensitive.bank'
      # If you don't want an extension to be loaded from the Chrome Web Store (or can't),
      # but rather from a local directory specified in tool:chrome:ext_local_source,
      # set local to true and make sure to provide e.g. metamask.crx in there. You will
      # also need to specify the extension version and change it when you update the file
      # to make Chrome aware of it.
      - metamask:
          local: true
          local_version: '10.8.1'
          blocked_permissions:
            - geolocation
          toolbar_pin: force_pinned
    # Specify global Chrome policies here. There are two types, managed (=forced) and
    # recommended (default, but modifiable by users)
    policies:
      forced:
        SSLErrorOverrideAllowed: false
        SSLVersionMin: tls1.2
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
    # Windows-specific settings when using policies, defaults as seen below
    # To be able to use Group Policies, this formula needs to ensure the ADML/X templates are available.
    win_gpo_owner: Administrators
    win_gpo_policy_dir: C:/Windows/PolicyDefinitions
    win_gpo_lang: en_US
    # this is the official source for the templates, it's not versioned. this is default
    win_gpo_source: https://dl.google.com/dl/edgedl/chrome/policy/policy_templates.zip
    # specify the source hash to enable verification. by default, verification is skipped (not recommended)
    win_gpo_source_hash: 25c6819e38e26bf87e44d3a0b9ac0cc0843776c271a6fa469679e7fae26a1591

    defaults:   # user-level defaults
      flags: []
```

## Notes
- Chrome/Chromium somehow comply to XDG spec, but forcing it on MacOS would put cache into profile dir in XDG_CONFIG_HOME. also dotfiles are not really a thing
- installation from local source is possible by adding `file:///absolute/path/*` to `ExtensionInstallSources` in **enforced** policies
- distinction between managed=forced and recommended:
  + Linux: /etc/opt/chrome/policies/{managed, recommended}
  + MacOS: (system) profile (plist in `/Library/Managed Preferences[/$USER]`) vs plist in `~/Library/Preferences`
  + Windows: `Google Chrome` vs `Google Chrome – Default Settings (users can override)`
- ExtensionSettings needs to be [minified JSON on Windows](https://support.google.com/chrome/a/answer/7532015)

### User Data Directories
(relative to user home)
```yaml
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
```

## Todo
- allow syncing master_preferences (default settings for new profiles)
- actually manage user-specific settings
- automatically download external extensions, only request link to `update.xml`
- 
## References
- https://www.chromium.org/administrators/configuring-other-preferences
- https://www.chromium.org/administrators/linux-quick-start
- https://chromeenterprise.google/policies/
- https://support.google.com/chrome/a/answer/9037717
- https://chromium.googlesource.com/chromium/chromium/+/refs/heads/main/chrome/app/policy/policy_templates.json
- https://chromium.googlesource.com/chromium/chromium/+/refs/heads/main/chrome/app/policy/syntax_check_policy_template_json.py
- https://support.google.com/chrome/a/answer/187202?ref_topic=9023406&hl=en
- https://support.google.com/chrome/a/answer/2657289
- https://github.com/andrewpmontgomery/chrome-extension-store
- https://www.chromium.org/administrators/mac-quick-start
- https://support.google.com/chrome/a/answer/9867568?hl=en&ref_topic=9023246
- https://sunweavers.net/blog/node/135
- https://docs.google.com/document/d/1pT0ZSbGdrbGvuCsVD2jjxrw-GVz-80rMS2dgkkquhTY/

## Further reading
- https://www.debugbear.com/chrome-extension-performance-lookup
