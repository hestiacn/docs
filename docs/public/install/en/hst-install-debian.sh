#!/bin/bash

#----------------------------------------------------------#
#                   Hestia Access Info                     #
#----------------------------------------------------------#
if command -v lsb_release >/dev/null; then
    os_name=$(lsb_release -sd | tr -d '"')
elif [ -f /etc/os-release ]; then
    . /etc/os-release
    os_name="${PRETTY_NAME:-$NAME}"
elif [ -f /etc/redhat-release ]; then
    os_name=$(sed 's/ release//' /etc/redhat-release)
elif [ -f /etc/debian_version ]; then
    os_name="Debian $(cat /etc/debian_version)"
else
    os_name="Unknown OS ($(uname -sr))"
fi
# Comparing hostname and IP
host_ip=$(host $servername | head -n 1 | awk '{print $NF}')
if [ "$host_ip" = "$ip" ]; then
	ip="$servername"
fi

echo -e "\n"
echo "===================================================================="
echo -e "\n"

# Sending notification to admin email
echo -e "Congratulations!\n\nYou have successfully installed Hestia $HESTIA_INSTALL_VER control panel on your $os_name server.

Ready to get started? Log in using the following credentials:

	Admin URL:  https://$servername:$port" > $tmpfile
if [ "$host_ip" != "$ip" ]; then
	echo "	Backup URL: https://$ip:$port" >> $tmpfile
fi
echo -e -n " 	Username:   $username
	Password:   123456

Thank you for choosing Hestia Control Panel to power your full stack web server,
we hope that you enjoy using it as much as we do!

Please feel free to contact us at any time if you have any questions,
or if you encounter any bugs or problems:

Documentation:  https://docs.hestiacp.com/
Forum:          https://forum.hestiacp.com/
GitHub:         https://www.github.com/hestiacp/hestiacp

Note: Automatic updates are enabled by default. If you would like to disable them,
please log in and navigate to Server > Updates to turn them off.

Help support the Hestia Control Panel project by donating via PayPal:
https://www.hestiacp.com/donate

--
Sincerely yours,
The Hestia Control Panel development team

Made with love & pride by the open-source community around the world.
" >> $tmpfile