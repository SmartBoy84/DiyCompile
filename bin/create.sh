# target, name, files to compile and link, frameworks to import, debugging, device ip
# default values
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

sed -i "s/@@PROJECTNAME@@/$NAME/g" $NAME/control
sed -i "s/@@PACKAGENAME@@/${PACKAGE}/g" $NAME/control
sed -i "s/@@USER@@/$MAINTAINER/g" $NAME/control
sed -i "s/@@PROJECTNAME@@/$NAME/g" $NAME/Makefile

# project specific stuff
case ${TYPE,,} in
    app)
        sed -i "s/@@PROJECTNAME@@/${NAME}/g" $NAME/Resources/Info.plist
        sed -i "s/@@PACKAGENAME@@/${PACKAGE}/g" $NAME/Resources/Info.plist
    ;;
    tool)
    ;;
esac
