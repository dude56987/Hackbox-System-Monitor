#! /bin/bash
########################################################################
# hackbox-system-monitor CLI for administration
# Copyright (C) 2016  Carl J Smith
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
########################################################################
if [ "$1" == "-h" ] || [ "$1" == "--help" ] || [ "$1" == "help" ] ;then
	echo "########################################################################"
	echo "# hackbox-system-monitor CLI for administration"
	echo "# Copyright (C) 2016  Carl J Smith"
	echo "#"
	echo "# This program is free software: you can redistribute it and/or modify"
	echo "# it under the terms of the GNU General Public License as published by"
	echo "# the Free Software Foundation, either version 3 of the License, or"
	echo "# (at your option) any later version."
	echo "#"
	echo "# This program is distributed in the hope that it will be useful,"
	echo "# but WITHOUT ANY WARRANTY; without even the implied warranty of"
	echo "# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the"
	echo "# GNU General Public License for more details."
	echo "#"
	echo "# You should have received a copy of the GNU General Public License"
	echo "# along with this program.  If not, see <http://www.gnu.org/licenses/>."
	echo "########################################################################"
	echo "HELP INFO"
	echo "This is the hackbox-system-monitor administration and update program."
	echo "To return to this menu use 'hackbox-system-monitor help'"
	echo "Other commands are listed below."
	echo ""
	echo "update"
	echo "  This will update the webpages and refresh the graphs."
	echo "lock"
	echo "  This will lock the web administration interface to only"
	echo "  allow users added to the created .htpasswd file."
	echo "unlock"
	echo "  This will allow everyone to access the webpages."
	echo "add"
	echo "  This will run a wizard that will let you add a new"
	echo "  user."
	echo "delete"
	echo "  This will run a wizard that will let you remove a"
	echo "  existing user."
	echo "list"
	echo "  This will list all existing users."
	echo "edit"
	echo "  This will bring up nano so you can edit the"
	echo "  .htpasswd file by hand."
	echo "########################################################################"
elif [ "$1" == "update" ];then
	# for each module defined in the conf file for updates
	for line in $(cat /etc/hackbox-system-monitor/modules.conf|grep -v '#');do
		echo "###########################################################"
		echo "Running script $line"
		echo "###########################################################"
		# run that script
		bash /usr/share/hackbox-system-monitor/modules/$line
		echo "###########################################################"
		echo "Script $line has finished."
		echo "###########################################################"
	done
elif [ "$1" == "lock" ];then
	link /etc/hackbox-system-monitor/templates/htaccess /var/cache/hackbox-system-monitor/.htaccess
	echo "All users must now provide a username and password before entering the website."
	echo "For help managing users access the help menu with 'hackbox-system-monitor help'"
elif [ "$1" == "unlock" ];then
	# remove the .htaccess and .htpasswords to disable website logins
	rm /var/cache/hackbox-system-monitor/.htaccess || echo 'Already unlocked!'
	echo "User login to the Hackbox System Monitor website has been disabled."
	echo "A login is no longer required to access the web interface."
elif [ "$1" == "add" ];then
	existingAccounts=$(cat /etc/hackbox-system-monitor/templates/htpasswd)
	existingAccounts=$(echo "$existingAccounts" | sed -e "s/\:.*$//g")
	headerString="Existing Accounts:\n$existingAccounts\n\nType a new name for a new user account.\nType a existing name to change the password."
	output=$(dialog --inputbox "$headerString" 24 80 --output-fd 1)
	# if the user typed something
	if [ $? == 0 ] && [ $output != "" ];then
		# add a new user to the .htpasswd file
		# use -B to use stronger encryption
		htpasswd -B /etc/hackbox-system-monitor/templates/htpasswd $output
		echo "User $output has been added to the list of allowed users and the password was updated."
	fi
elif [ "$1" == "delete" ];then
	# load up the existing accounts to show them above the input form
	existingAccounts=$(cat /etc/hackbox-system-monitor/templates/htpasswd)
	existingAccounts=$(echo "$existingAccounts" | sed -e "s/\:.*$//g")
	output=$(dialog --inputbox "Existing Accounts:\n$existingAccounts\n\nType a username to delete that account." 24 80 --output-fd 1)
	# if the user typed something
	if [ $? == 0 ] && [ $output != "" ];then
		# run grep in inverted mode to show only nonmatching lines
		# pipe that back into the file to remove only one user line
		grep -v "^$output:" /etc/hackbox-system-monitor/templates/htpasswd > /etc/hackbox-system-monitor/templates/htpasswd
		echo "Deleted user $output from Hackbox System Monitor."
	fi
elif [ "$1" == "list" ];then
	# list the existing users
	existingAccounts=$(cat /etc/hackbox-system-monitor/templates/htpasswd)
	existingAccounts=$(echo "$existingAccounts" | sed -e "s/\:.*$//g")
	dialog --msgbox "Existing Accounts:\n$existingAccounts" 24 80
elif [ "$1" == "edit" ];then
	# edit the password users
	vim /etc/hackbox-system-monitor/templates/htpasswd
else
	# if no arguments are given run the update then help commands.
	hackbox-system-monitor update
	hackbox-system-monitor help
fi
