# target, name, files to compile and link, frameworks to import, debugging, device ip

# makefile defaults
CLIENT="root@carrot"
OS="14.4"
ARCH="arm64"

# control default
TYPE=""
NAME=""
PACKAGE=""
MAINTAINER=$USER

# select type
templates=($DIYCOMPILE/templates/*)
echo $templates

for i in "${!templates[@]}"; do templates[$i]=${templates[$i]##*/}; done
select option in ${templates[*]}; do # in "$@" is the default
    if [ 1 -le "$REPLY" ] && [ "$REPLY" -le $((${#templates[@]})) ];
    then
        TYPE=$option;
        break;
    else
        echo "Select a number [1-${#templates[@]}]"
    fi
done


while true; do
    read -p "Project name: " NAME
    if [ -z "$NAME" ]; then
        echo "I need a name, man!"
        elif [ -d $NAME ]; then
        echo "Folder with that name already exists"
    else
        break
    fi
done

PACKAGE="com.barfie.$NAME"
read -p "Package name [$PACKAGE]:" _PACKAGE
if [[ ! -z "$_PACKAGE" ]]; then
    PACKAGE=$_PACKAGE
fi
read -p "Maintainer [$MAINTAINER]:" _MAINTAINER
if [[ ! -z "$_MAINTAINER" ]]; then
    MAINTAINER=$_MAINTAINER
fi

mkdir $NAME
cp -r $DIYCOMPILE/templates/$TYPE/* $NAME &> /dev/null

# project specific stuff
case ${TYPE,,} in
    swifp)
        sed -i "s/@@PACKAGENAME@@/$NAME/g" ${NAME}/src/App.swift
    ;;
    rust|rusp)
        sed -i "s/@@PACKAGENAME@@/\"$NAME\"/g" ${NAME}/Cargo.toml
        rustup target add aarch64-apple-ios # I can't be arsed, if you want custom args then add them yourself
    ;;
esac

# set control variable
sed -i "s/@@PROJECTNAME@@/$NAME/g" $NAME/control
sed -i "s/@@PACKAGENAME@@/$PACKAGE/g" $NAME/control
sed -i "s/@@USER@@/$MAINTAINER/g" $NAME/control

# set makefile variable
sed -i "s/@@PROJECTNAME@@/$NAME/g" $NAME/Makefile

# set makefile constant
sed -i "s/@@CLIENT@@/$CLIENT/g" $NAME/Makefile
sed -i "s/@@OS@@/$OS/g" $NAME/Makefile
sed -i "s/@@ARCH@@/$ARCH/g" $NAME/Makefile

if [[ -f "$NAME/Info.plist" ]]; then
    sed -i "s/@@PROJECTNAME@@/${NAME}/g" $NAME/Info.plist
    sed -i "s/@@PACKAGENAME@@/${PACKAGE}/g" $NAME/Info.plist
    sed -i "s/@@VERSION@@/${OS}/g" $NAME/Info.plist
fi