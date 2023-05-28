SPM!!! (look at orion tweak, does pretty much everything)
Add swiftformat as a dependecy
just give up and use makefiles like they're meant to be used - individually compile the files and manually link them together (rather than do that weird hack in scout, compile.mk)

## Linker arguments
Allow user to specify linker arguments
Specific types and then handle it differently

## Library support
Allow user to specify frameworks to add
If framework exists, then if the framework is present as a binary, take it's info.plist and the binary and bundle it in the executabl's application folder
If this needs to be done then switch to "/Application" mode
Set rpath to be its install path/Frameworks
