SPM!!! (look at orion tweak, does pretty much everything)
Add swiftformat as a dependecy
just give up and use makefiles like they're meant to be used - individually compile the files and manually link them together (rather than do that weird hack in scout, compile.mk)

## Library support
Allow user to specify frameworks to add
If framework exists in lib or whatever path user has specified, then if the framework is present as a binary, take it's info.plist and the binary and bundle it in the executabl's application folder
If this needs to be done then switch to "/Application" mode
Set rpath to be its install path/Frameworks
