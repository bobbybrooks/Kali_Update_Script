#!/bin/sh

################################################################################
#
#  FILE: Kali2_Update_Script.sh
#
#  AUTHOR: Bobby Brooks
#
#  DATE: 22 August 2015
#
#  PROBLEM: After stock Kali install, there are several adjustments that need 
#  to be made and software packages that need to be downloaded, installed, 
#  customized depending on individual tastes and system requirements.
#  
#  PURPOSE: See https://github.com/bobbybrooks/Kali_Update_Script/blob/master/Kali_Update_Script_current.sh
#  The original designed script worked on Kali 1.x, this is the changes necessary for version 2.0x
#
#  STATUS: Under revision (22 August 2015)
#
#  NOTES: 
#
#		
#
#
#  USE:		- Install Kali Linux from DVD (ISO)
#			- After initial login, wget this script
#			- Identify changes needed and comment out unwanted portions
#			- chmod +x ThisScript and enter new username/password
#			- Once complete, validate all software is updated
#
#  REFS: 20 things to do after installing Kali Linux (blackMORE Ops)
#	http://www.blackmoreops.com/2014/03/03/20-things-installing-kali-linux/
#
#  HISTORY:
#       22 August 2015 - 0.1
#
#  TESTING:
#		- Full tool listing found here: http://tools.kali.org/tools-listing
#
################################################################################

################################################################################
#
# Add a standard user
# User input for username and password
echo -n "Enter your desired username: "
read username
echo -n "Enter your password - Don't lose this: "
read password

# Start the magic with the input
useradd -m $username

### THIS GIVES AN UNSECURE PASSWORD...CHANGE UPON LOGIN!!!
echo "$username:$password" | chpasswd
usermod -a -G sudo $username
chsh -s /bin/bash $username
#
# Provide environment to $username
cp /root/.bashrc /home/$username/.bashrc
mkdir /home/$username/Desktop && chown $username /home/$username/Desktop && chgrp $username /home/$username/Desktop

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ERROR CHECKING
#
touch /home/$username/Desktop/errorcheck.sh
echo '#!/bin/bash' >> /home/$username/Desktop/errorcheck.sh
echo ' ' >> /home/$username/Desktop/errorcheck.sh
echo '# Verify network managed (if you want it to be)' >> /home/$username/Desktop/errorcheck.sh
echo 'cat /etc/NetworkManager/NetworkManager.conf | grep managed=true' >> /home/$username/Desktop/errorcheck.sh
echo '#' >> /home/$username/Desktop/errorcheck.sh
echo '# Verify all software is updated' >> /home/$username/Desktop/errorcheck.sh
echo 'gpk-update-viewer' >> /home/$username/Desktop/errorcheck.sh
echo 'read -p "Script complete.  Press [Enter] key to exit" ' >> /home/$username/Desktop/errorcheck.sh
#
# Make the sh executable
chmod a=r+w+x /home/$username/Desktop/errorcheck.sh

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
## Network Manager (I don't do this because it caused me issues, but in case it's
## needed, here's the config location
## Backup first 
#cp /etc/NetworkManager/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf.old
## Replace false with true
#sed -i -e 's/managed=false/managed=true/g' /etc/NetworkManager/NetworkManager.conf

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Clean, update, upgrade and dist-upgrade your Kali installation. (LONG TIME)

apt-get clean
apt-get update
echo '/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\'
echo 'This process is going to take awhile'
echo '\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/'
apt-get upgrade -y -qq
apt-get dist-upgrade -y

# In case it didn't get installed, implicitly install updated jdk
apt-get install default-jdk

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Configurations

# Enable sound on Boot
apt-get install alsa-utils -y

# VM tools (obviously comment this out if not on a VM)
apt-get install open-vm-tools-desktop -y
apt-get install open-vm-tools -y

## In case you need Flash, recommend not installing it
#apt-get install flashplugin-nonfree
#update-flashplugin-nonfree --install

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Additional Software

# Tor (using iceweasel)
# Start with script: sudo service tor start && proxychains iceweasel
apt-get install tor -y
# Uncomment line below (it's a long line) to add script to desktop to start tor browser
#
#touch /home/$username/Desktop/tor-browser.sh && chmod +x /home/$username/Desktop/tor-browser.sh && echo '#!/bin/bash' >> /home/$username/Desktop/tor-browser.sh && echo ' ' >> /home/$username/Desktop/tor-browser.sh && echo 'sudo service tor start && proxychains iceweasel' >> /home/$username/Desktop/tor-browser.sh && echo 'sudo service tor stop' >> /home/$username/Desktop/tor-browser.sh && echo 'read -p "Tor Browsing Completed.  Press [Enter] key to exit" ' >> /home/$username/Desktop/tor-browser.sh


# File Roller - Archive Manager
apt-get install unrar unace rar unrar p7zip zip unzip p7zip-full p7zip-rar file-roller -y

# Filezilla FTP Client
apt-get install filezilla filezilla-common -y

# HTOP and NetHogs
apt-get install htop -y
apt-get install nethogs -y

# Terminator
apt-get install terminator -y

# GDebi Package Manager
apt-get install gdebi -y

# Chrome browser
apt-get install chromium -y

# xchat, since I always need to connect to IRC for CtF's
apt-get install xchat -y

# xfce (since I hate the new interface and xfce is so much cleaner)
# when logging in after reboot, click the wheel below the password and select xfce
apt-get install kali-defaults kali-root-login desktop-base xfce4 xfce4-places-plugin xfce4-goodies


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Finally, reboot
reboot

