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

folders=()
count=1

for template in "${templates[@]}"; do
  if [ -d "$template" ]; then
    folder_name=$(basename "$template")
    folders[count]="$folder_name"
    ((count++))
  fi
done

select option in "${folders[@]}"; do
  if [ 1 -le "$REPLY" ] && [ "$REPLY" -le $((${#folders[@]})) ]; then
    TYPE=${folders[$REPLY]}
    break
  else
    echo "Select a valid number [1-${#folders[@]}]"
  fi
done

while true; do
    read -p "Project name: " NAME
    if [[ -z "$NAME" ]]; then
        echo "I need a name, man!"
    elif [[ "$NAME" =~ [\ ] ]]; then
        echo "Name cannot contain spaces."
    elif [[ -d "$NAME" ]]; then
        echo "Folder with that name already exists."
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

# do any preliminary set up
cd $NAME && make config