```
# todo
# Gradi_PRIVATE_FRAMEWORKS = CoverSheet PlatterKit SpringBoard MediaRemote FrontBoard

# DEBUG = 1

# ENTITLEMENTS = entitlements.plist
# INSTALL_PATH = /usr/local/bin

# specify custom flags, e.g., CUSTOM_GO
# CUSTOM_$(LANG) =

# Following will enable /Applications hack and bundle framework/files
# FRAMEWORKS = HaishinKit
# RESOURCES = Resources/*

# symlinks binary into it's own folder in /Applicatiosn to trick iOS into giving it perms (by reading it's TCC.db entry) that would otherwise require user interaction (e.g., location services)
# unfortunately, Info.plist is required and that causea a dummy app icon to appear
# GIMME_PERM = 1

# this is a niche option and doesn't need to be specified unless using an Info.plist is an odd location or if using a custom template
# if it is ever needed, make system creates it automatically
# INFO = Info.plist

# PORT = 22

# this is for personal use, checkout (this)[https://github.com/SmartBoy84/Weazol/]!
#TRUST_BIN = /trust
```