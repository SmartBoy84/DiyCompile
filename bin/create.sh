# target, name, files to compile and link, frameworks to import, debugging, device ip
NAME=""
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

MAINTAINER=$USER
read -p "Maintainer [$MAINTAINER]:" _MAINTAINER
if [[ ! -z "$_MAINTAINER" ]]; then
    MAINTAINER=$_MAINTAINER
fi

mkdir $NAME
cp -r $DIYCOMPILE/app/* $NAME &> /dev/null

sed -i "s/@@PROJECTNAME@@/$NAME/g" $NAME/control
sed -i "s/@@PACKAGENAME@@/${PACKAGE}/g" $NAME/control
sed -i "s/@@USER@@/$MAINTAINER/g" $NAME/control

sed -i "s/@@PROJECTNAME@@/${NAME}/g" $NAME/Resources/Info.plist
sed -i "s/@@PACKAGENAME@@/${PACKAGE}/g" $NAME/Resources/Info.plist

sed -i "s/@@PROJECTNAME@@/$NAME/g" $NAME/Makefile
