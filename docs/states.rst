Available states
----------------

The following states are found in this formula:

.. contents::
   :local:


``tool_chrome``
~~~~~~~~~~~~~~~
*Meta-state*.

Performs all operations described in this formula according to the specified configuration.


``tool_chrome.package``
~~~~~~~~~~~~~~~~~~~~~~~
Installs the Google Chrome package only.


``tool_chrome.package.repo``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
This state will install the configured Google Chrome repository.
This works for apt/dnf/yum/zypper-based distributions only by default.


``tool_chrome.local_extensions``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_chrome.flags``
~~~~~~~~~~~~~~~~~~~~~



``tool_chrome.policies``
~~~~~~~~~~~~~~~~~~~~~~~~



``tool_chrome.policies.winadm``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_chrome.default_profile``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_chrome.clean``
~~~~~~~~~~~~~~~~~~~~~
*Meta-state*.

Undoes everything performed in the ``tool_chrome`` meta-state
in reverse order.


``tool_chrome.package.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Removes the Google Chrome package.


``tool_chrome.package.repo.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
This state will remove the configured Google Chrome repository.
This works for apt/dnf/yum/zypper-based distributions only by default.


``tool_chrome.local_extensions.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_chrome.flags.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_chrome.policies.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_chrome.policies.winadm.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



