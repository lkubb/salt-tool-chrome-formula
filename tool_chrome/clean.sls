# vim: ft=sls

{#-
    *Meta-state*.

    Undoes everything performed in the ``tool_chrome`` meta-state
    in reverse order.
#}

include:
  - .policies.clean
  - .flags.clean
  - .local_extensions.clean
  - .package.clean
