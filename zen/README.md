---
id: 8f9a0b1c-2d3e-4f5a-6b7c-8d9e0f1a2b3c
title: Zen Browser Profile
created: 2025-12-13T00:00:00
updated: 2025-12-13T17:04
project: dotfiles
scope:
  - applications
  - browser
type: reference
status: ✅ active
publish: false
tags:
  - zen
  - browser
  - firefox
aliases:
  - zen-profile
related: []
---

# Profile Folder

profile folder: `/Users/asmith/Library/Application Support/Firefox/Profiles/39jgrhc7.default-release`

## Setup Requirements

```
brew install zen@twilight
brew install opensc
echo /opt/homebrew/Cellar/opensc/$(brew list opensc --versions | awk '{print $2}')/lib/pkcs11/opensc-pkcs11.so
open zen
cmd+L -> about:preferences#privacy

To debug smart card certificates in Firefox on macOS, first install a PKCS#11 driver to access your smart card, such as keychain-pkcs11. Then, in Firefox settings, go to Preferences > Privacy & Security > Security Devices and click Load to add your PKCS#11 driver path (e.g., /Library/OpenSC/lib/opensc-pkcs11.so). Finally, visit a website that requires client certificate authentication, and if prompted to select a certificate, check Firefox to see if it can detect and load your smart card certificate to verify the connection.
1. Install a PKCS#11 Driver
Smart cards require a PKCS#11 driver to communicate with applications like Firefox.

    Download a driver:

Download a PKCS#11 driver, such as the keychain-pkcs11 package from its GitHub releases page.
Install the driver:

    Open the downloaded .pkg file and follow the installation prompts, providing your administrator password when requested.

2. Configure Firefox to Use the Driver

    Open Firefox: and type about:preferences into the address bar to go to the Preferences page.

Click Privacy & Security in the sidebar.
Scroll down to the Security section and click Security Devices.
In the "Security Devices" pop-up, click Load.
Enter a descriptive name for the device (e.g., "SmartCard").
In the Module Path field, type the path to the installed PKCS#11 driver, such as /Library/OpenSC/lib/opensc-pkcs11.so for the OpenSC driver, or /usr/local/lib/libccid.dylib or /usr/local/lib/libeToken.dylib for other drivers.
Click OK to add the driver to Firefox.

3. Test Smart Card Authentication

    Navigate: to a website that requires a client certificate for authentication.

If the website prompts you to select a client certificate, observe if Firefox lists your smart card certificate as an option.
Enter: your smart card PIN if prompted to complete the authentication.

Troubleshooting Tips

    Restart Firefox

and the system after installing the PKCS#11 driver, especially if you encounter issues.
Insert the smart card
before launching Firefox, as some users have found that inserting it after Firefox starts can cause the browser to freeze.
Import trusted CAs:
If the website isn't trusted, make sure the CA certificate that issued the smart card certificate is imported into Firefox's certificate manager and marked as trusted for website identification.


To download a PKCS#11 driver for Firefox on macOS, you must first determine which PKCS#11 module is compatible with your device or security token, such as a smart card or USB key. A common option is to use the OpenSC PKCS#11 Module, which can be installed using a package manager like MacPorts via the command sudo port install opensc in the Terminal. After installation, you then load the driver within Firefox's settings by going to Settings > Privacy & Security > Certificates > Security Devices, clicking Load, and entering the module name (e.g., OpenSC PKCS#11 Module).

. Identify the Correct PKCS#11 Driver

    Consult your device manufacturer:

The most important step is to find the specific PKCS#11 driver provided by the manufacturer of your smart card, USB token, or other security device.
Consider OpenSC:

    If your hardware is not supported by a specific driver or you prefer an open-source option, the OpenSC PKCS#11 module is a popular alternative.

2. Install the Driver (if needed)

    Using MacPorts (for OpenSC):
        Open the Terminal application on your Mac (Applications > Utilities > Terminal).
        Run the following command to install OpenSC: sudo port install opensc.

3. Load the Driver in Firefox

    Open Firefox.
    Click the menu button (three horizontal stripes) or navigate to the Firefox menu in the top bar.
    Select Settings (or Options).
    In the left-hand menu, click on Privacy & Security.
    Scroll down to the Certificates section and click the Security Devices button.
    In the Device Manager window, click the Load button.
    In the "Module Name" field, enter the name of the PKCS#11 module, for example, OpenSC PKCS#11 Module, and click OK
```
