Make sure to run `./bin/bootsrap.sh` (gets 14.5 sdk and sbigner's swift toolchain)\
Run `./bin/create.sh` to access templating interface\
Buildsystem expects `$DIYCOMPILE` to point to whereever the directory is cloned before it's run (specify custom directory by changing `$DIR` in `./makefiles/common.mk`

For swift cli apps, it is possible to obtain permissions simply by setting them in the info.plist

Makes compilation for ios super easy on other devices
Can compile IPAs
`GIMME_PERM` to allow cli apps to access camera, mic, gps etc
