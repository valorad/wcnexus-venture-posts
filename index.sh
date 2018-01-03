#!/bin/sh
# This file is used to change permission for a normal user on docker container run.

username=$EXEC_USER
userid=${EXEC_USER_ID}

# Add local user
echo "Summoning $username - UID:$userid ..."
adduser $username -u $userid -D -s /bin/sh
chown -R $username /src
chmod -R 755 /src
chown -R $username /dist
chmod -R 755 /dist

# Fetch theme
# function fetchTheme() {
#   rm -rf /src/themes/*
#   wget -O /tmp/theme.zip https://github.com/$(wget https://github.com/valorad/wcnexus-venture-theme/releases/latest -O - | egrep '/.*releases/.*/.*zip' -o)
#   mkdir -p /src/themes/wcnexus-venture
#   unzip -d /src/themes/wcnexus-venture/ /tmp/theme.zip
# }

# su-exec $username fetchTheme()
# /bin/sh
su-exec $username "$@"
