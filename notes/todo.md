SPM!!! (look at orion tweak, does pretty much everything)
Add swiftformat as a dependecy
just give up and use makefiles like they're meant to be used - individually compile the files and manually link them together (rather than do that weird hack in scout, compile.mk)

## rust support
cc compilation not working unless I symlink clang to /bin/cc
bevy crashes on startup (at least with simple example) - verify objc compilation via some other means (audio, touch, haptic, LOCATION etc)