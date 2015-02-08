#!/bin/sh

################################################################################
#
#  FILE: Kali_Update_Script.txt
#
#  AUTHOR: Bobby Brooks
#
#  DATE: 28 July 2014
#
#  CLASS: N/A
#
#  INSTRUCTOR: N/A
#
#  PROBLEM: After stock Kali install, there are several adjustments that need 
#  to be made and software packages that need to be downloaded, installed, 
#  customized depending on individual tastes and system requirements.
#  
#  PURPOSE: 
#
#
#  STATUS: Peer Review (1 December 2014)
#
#  NOTES: 
#	Thinking about starting the metasploit service and postgresql automatically at startup
#		
#
#
#  USE: Install Kali Linux from DVD (ISO).  After initial login, identify 
#  software to load (comment out unwanted software) and username run script 
#  and identify username and password to be created.
#	-Run script: sh ./kali_update_script.txt and enter desired user/pass
#	-Once Complete, validate installs with errorcheck.sh on user's Desktop
#
#
#  REFS: 20 things to do after installing Kali Linux (blackMORE Ops)
#	http://www.blackmoreops.com/2014/03/03/20-things-installing-kali-linux/
#
#  HISTORY:
#       29 July 2014 - 0.1
#
#  TESTING:
#	28 July 2014 - validated
#		VMWare Workstation 9.0.2 build-1031769
#		Kali 1.0.7
#	29 July 2014 - Fixed errors
#		Have user enter user/pass to create
#		Included code to make script executable
#		Added pause function at end
#	30 July 2014 - Submitted for peer review
#	11 August 2014 - Updated java to 1.8.0_11
#	26 August 2014 - Updated java to 1.8.0_20
#	23 October 2014 - Updated java to 1.8.0_25		
#	1 December 2014 - Added script to check for 32bit or 64bit and update 
#		java info dynamically
# 8 February 2015 - Automatically pulls newest version of java with apt-get jdk
#
#
################################################################################

################################################################################
### Creating user first to set variables
### 9. Add a standard user
# Kali Linux got only root user by default. While most applications require 
# root access, itâ€™s always a good idea to add a second user. 

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

# This sets the bits variable to either 686 or amd64 (32 bit or 64 bit) for updating java (and maybe more)
bits=`uname -a | cut -f 3 -d " " | cut -f 3 -d "-"`
################################################################################


################################################################################
# ERROR CHECKING
################################################################################
#

touch /home/$username/Desktop/errorcheck.sh
echo '#!/bin/bash' >> /home/$username/Desktop/errorcheck.sh
echo ' ' >> /home/$username/Desktop/errorcheck.sh
echo '# Verify network managed' >> /home/$username/Desktop/errorcheck.sh
echo 'cat /etc/NetworkManager/NetworkManager.conf | grep managed=true' >> /home/$username/Desktop/errorcheck.sh
echo '#' >> /home/$username/Desktop/errorcheck.sh
echo '# Verify sound is configured' >> /home/$username/Desktop/errorcheck.sh
echo 'cat /etc/default/pulseaudio | grep PULSEAUDIO_SYSTEM_START=1' >> /home/$username/Desktop/errorcheck.sh
echo '#' >> /home/$username/Desktop/errorcheck.sh
echo '# Verify flash is updated - Should say 0 upgraded, newly installed, remove, not upgraded' >> /home/$username/Desktop/errorcheck.sh
echo 'sudo apt-get dist-upgrade flash-plugin-nonfree | grep upgraded' >> /home/$username/Desktop/errorcheck.sh
echo '#' >> /home/$username/Desktop/errorcheck.sh
echo '# verify java installed' >> /home/$username/Desktop/errorcheck.sh
echo 'java -version' >> /home/$username/Desktop/errorcheck.sh
echo '#' >> /home/$username/Desktop/errorcheck.sh
echo '# Verify all software is updated' >> /home/$username/Desktop/errorcheck.sh
echo 'gpk-update-viewer' >> /home/$username/Desktop/errorcheck.sh
echo 'read -p "Script complete.  Press [Enter] key to exit" ' >> /home/$username/Desktop/errorcheck.sh


# Make the sh executable
chmod a=r+w+x /home/$username/Desktop/errorcheck.sh

################################################################################
######### I don't do this because it caused issues with my connection ##########
### 1. Fix Device not managed error â€“ wired network

# Backup file
cp /etc/NetworkManager/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf.old

# Replace false with true
sed -i -e 's/managed=false/managed=true/g' /etc/NetworkManager/NetworkManager.conf
################################################################################

################################################################################
### 2. Fix default repository
# Backup file
mv /etc/apt/sources.list /etc/apt/sources.list.old

# Insert new lines into /etc/apt/sources.list
touch /etc/apt/sources.list

cat << ENDOFSOURCESLIST >> /etc/apt/sources.list

## Verifies this is /etc/apt/sources.list
## Regular repositories
deb http://http.kali.org/kali kali main non-free contrib
deb http://security.kali.org/kali-security kali/updates main contrib non-free
## Source repositories
deb-src http://http.kali.org/kali kali main non-free contrib
deb-src http://security.kali.org/kali-security kali/updates main contrib non-free

ENDOFSOURCESLIST

################################################################################

### 3. Update, Upgrade, Dist-Upgrade
# Clean, update, upgrade and dist-upgrade your Kali installation. (LONG TIME)

apt-get clean
apt-get update
echo '/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\'
echo 'This process is going to take awhile'
echo '\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/'
apt-get upgrade -y -qq
apt-get dist-upgrade -y

################################################################################
### 4. Fix PulseAudio warning
# If you get this error:
# [warn] PulseAudio configured for per-user sessions ... (warning).
# Backup file
cp /etc/default/pulseaudio /etc/default/pulseaudio.old
sed -i -e 's/PULSEAUDIO_SYSTEM_START=0/PULSEAUDIO_SYSTEM_START=1/g' /etc/default/pulseaudio
################################################################################


################################################################################
### 5. Enable sound on Boot
# Follow the steps below to fix sound mute in Kali Linux on boot
apt-get install alsa-utils -y
################################################################################

################################################################################
########### Filename must be changed...current is 1.8.0_11 and 8u11 ############
## Must update the download link to the current version  This version is 8u11 ##

### 6. Install Java
# can just use apt-get to bypass all the cool code below:
# apt-get install default-jdk

# Renamed java download page to local page
wget -v http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html && mv ./jdk8-downloads-2133151.html ./java-download.html
major_version_x86=`cat java-download.html | grep i586.tar.gz | cut -d "'" -f 7 | cut -d '"' -f 12 | cut -d "/" -f 7 | cut -d "-" -f 1 | cut -d "u" -f 1`
minor_version_x86=`cat java-download.html | grep i586.tar.gz | cut -d "'" -f 7 | cut -d '"' -f 12 | cut -d "/" -f 7 | cut -d "-" -f 1 | cut -d "u" -f 2` 
revision_x86=`cat java-download.html | grep i586.tar.gz | cut -d "'" -f 7 | cut -d '"' -f 12 | cut -d "/" -f 7 | cut -d "-" -f 2`

major_version_x64=`cat java-download.html | grep linux.x64.tar.gz | cut -d "'" -f 7 | cut -d '"' -f 12 | cut -d "/" -f 7 | cut -d "-" -f 1 | cut -d "u" -f 1`
minor_version_x64=`cat java-download.html | grep linux.x64.tar.gz | cut -d "'" -f 7 | cut -d '"' -f 12 | cut -d "/" -f 7 | cut -d "-" -f 1 | cut -d "u" -f 2` 
revision_x64=`cat java-download.html | grep linux.x64.tar.gz | cut -d "'" -f 7 | cut -d '"' -f 12 | cut -d "/" -f 7 | cut -d "-" -f 2`



# Check for 32 bit or 64 bit version

# This is the 64 bit version
if [ $bits == 'amd64' ]; 
	then
		cd ~
		curl -L -C - -b "oraclelicense=accept-securebackup-cookie" -O http://download.oracle.com/otn-pub/java/jdk/$major_version_x64"u"$minor_version_x64-$revision_x64/jdk-$major_version_x64"u"$minor_version_x64-linux-x64.tar.gz

		tar -xzvf /root/jdk-$major_version_x64"u"$minor_version_x64-linux-x64.tar.gz
		mv jdk1.$major_version_x64.0_$minor_version_x64 /opt
		cd /opt/jdk1.$major_version_x64.0_$minor_version_x64

		update-alternatives --install /usr/bin/java java /opt/jdk1.$major_version_x64.0_$minor_version_x64/bin/java 1
		update-alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_$minor_version_x64/bin/javac 1
		update-alternatives --install /usr/lib/mozilla/plugins/libjavaplugin.so mozilla-javaplugin.so /opt/jdk1.$major_version_x64.0_$minor_version_x64/jre/lib/amd64/libnpjp2.so 1
		update-alternatives --set java /opt/jdk1.$major_version_x64.0_$minor_version_x64/bin/java
		update-alternatives --set javac /opt/jdk1.$major_version_x64.0_$minor_version_x64/bin/javac
		update-alternatives --set mozilla-javaplugin.so /opt/jdk1.$major_version_x64.0_$minor_version_x64/jre/lib/amd64/libnpjp2.so
fi

#
# Hard coded link
#		curl -L -C - -b "oraclelicense=accept-securebackup-cookie" -O http://download.oracle.com/otn-pub/java/jdk/8u25-b17/jdk-8u25-linux-x64.tar.gz
#
#		tar -xzvf /root/jdk-8u25-linux-x64.tar.gz
#		mv jdk1.8.0_25 /opt
#		cd /opt/jdk1.8.0_25
################## Fileneames must be changed here as well ###################
#		update-alternatives --install /usr/bin/java java /opt/jdk1.8.0_25/bin/java 1
#		update-alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_25/bin/javac 1
#		update-alternatives --install /usr/lib/mozilla/plugins/libjavaplugin.so mozilla-javaplugin.so /opt/jdk1.8.0_25/jre/lib/amd64/libnpjp2.so 1
#		update-alternatives --set java /opt/jdk1.8.0_25/bin/java
#		update-alternatives --set javac /opt/jdk1.8.0_25/bin/javac
#		update-alternatives --set mozilla-javaplugin.so /opt/jdk1.8.0_25/jre/lib/amd64/libnpjp2.so



# This is the 32 bit version
if [ $bits == '686' ]; 
	then
		cd ~
		curl -L -C - -b "oraclelicense=accept-securebackup-cookie" -O http://download.oracle.com/otn-pub/java/jdk/$major_version_x86"u"$minor_version_x86-$revision_x86/jdk-$major_version_x86"u"$minor_version_x86-linux-i586.tar.gz

		tar -xzvf /root/jdk-$major_version_x86"u"$minor_version_x86-linux-i586.tar.gz
		mv jdk1.$major_version_x86.0_$minor_version_x86 /opt
		cd /opt/jdk1.$major_version_x86.0_$minor_version_x86

		update-alternatives --install /usr/bin/java java /opt/jdk1.$major_version_x86.0_$minor_version_x86/bin/java 1
		update-alternatives --install /usr/bin/javac javac /opt/jdk1.$major_version_x86.0_$minor_version_x86/bin/javac 1
		
		update-alternatives --install /usr/lib/mozilla/plugins/libjavaplugin.so mozilla-javaplugin.so /opt/jdk1.$major_version_x86.0_$minor_version_x86/jre/lib/i368/libnpjp2.so 1
		update-alternatives --set java /opt/jdk1.$major_version_x86.0_$minor_version_x86/bin/java
		update-alternatives --set javac /opt/jdk1.$major_version_x86.0_$minor_version_x86/bin/javac
		update-alternatives --set mozilla-javaplugin.so /opt/jdk1.$major_version_x86.0_$minor_version_x86/jre/lib/i386/libnpjp2.so
fi

#
# Hard coded link
#		curl -L -C - -b "oraclelicense=accept-securebackup-cookie" -O http://download.oracle.com/otn-pub/java/jdk/8u25-b17/jdk-8u25-linux-i586.tar.gz
#		tar -xzvf /root/jdk-8u25-linux-i586.tar.gz
#		mv jdk1.8.0_25 /opt
#		cd /opt/jdk1.8.0_25
################## Fileneames must be changed here as well ###################
#update-alternatives --install /usr/bin/java java /opt/jdk1.8.0_25/bin/java 1
#update-alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_25/bin/javac 1
#update-alternatives --install /usr/lib/mozilla/plugins/libjavaplugin.so mozilla-javaplugin.so /opt/jdk1.8.0_25/jre/lib/i368/libnpjp2.so 1
#update-alternatives --set java /opt/jdk1.8.0_25/bin/java
#update-alternatives --set javac /opt/jdk1.8.0_25/bin/javac
#update-alternatives --set mozilla-javaplugin.so /opt/jdk1.8.0_25/jre/lib/i386/libnpjp2.so




################################################################################
### 7. Install Flash
# This is fairly simple and easy and should work from most people out there: In the terminal:
apt-get install flashplugin-nonfree
update-flashplugin-nonfree --install

################################################################################
###
# 8. Install File Roller - Archive Manager (bottom)
###
# 9. Add a standard user (top) because it sets username variables
###
################################################################################
### 10. Add add-apt-repository

apt-get install python-software-properties -y

apt-get install apt-file -y

apt-file update

apt-file search add-apt-repository

################################################################################
echo '#!/bin/bash' >> /usr/sbin/add-apt-repository
echo ' '
echo 'if [ $# -eq 1 ]' >> /usr/sbin/add-apt-repository
echo 'NM=`uname -a && date`' >> /usr/sbin/add-apt-repository
echo 'NAME=`echo $NM | md5sum | cut -f1 -d" "`' >> /usr/sbin/add-apt-repository
echo 'then' >> /usr/sbin/add-apt-repository
echo '  ppa_name=`echo "$1" | cut -d":" -f2 -s`' >> /usr/sbin/add-apt-repository
echo '  if [ -z "$ppa_name" ]' >> /usr/sbin/add-apt-repository
echo '  then' >> /usr/sbin/add-apt-repository
echo '    echo "PPA name not found"' >> /usr/sbin/add-apt-repository
echo '    echo "Utility to add PPA repositories in your debian machine"' >> /usr/sbin/add-apt-repository
echo '    echo "$0 ppa:user/ppa-name"' >> /usr/sbin/add-apt-repository
echo '  else' >> /usr/sbin/add-apt-repository
echo '    echo "$ppa_name"' >> /usr/sbin/add-apt-repository
echo '    echo "deb http://ppa.launchpad.net/$ppa_name/ubuntu oneiric main" >> /etc/apt/sources.list' >> /usr/sbin/add-apt-repository
echo '    apt-get update >> /dev/null 2> /tmp/${NAME}_apt_add_key.txt' >> /usr/sbin/add-apt-repository
echo '    key=`cat /tmp/${NAME}_apt_add_key.txt | cut -d":" -f6 | cut -d" " -f3`' >> /usr/sbin/add-apt-repository
echo '    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $key' >> /usr/sbin/add-apt-repository
echo '    rm -rf /tmp/${NAME}_apt_add_key.txt' >> /usr/sbin/add-apt-repository
echo '  fi' >> /usr/sbin/add-apt-repository
echo 'else' >> /usr/sbin/add-apt-repository
echo '  echo "Utility to add PPA repositories in your debian machine"' >> /usr/sbin/add-apt-repository
echo '  echo "$0 ppa:user/ppa-name"' >> /usr/sbin/add-apt-repository
echo 'fi' >> /usr/sbin/add-apt-repository
################################################################################

#  Now chmod and chown the file
chmod o+x /usr/sbin/add-apt-repository 
chown root:root /usr/sbin/add-apt-repository

# Now that we added the correct code, we can use add-apt-repository to add a PPA repository. 
# I tried the following to add themes and custom icons in Kali Linux.
/usr/sbin/add-apt-repository ppa:noobslab/themes
/usr/sbin/add-apt-repository ppa:alecive/antigone

################################################################################

################################################################################
### 11. Install Tor

apt-get install tor -y

service tor start

# Use iceweasel with proxychains
### Will require user to close iceweasel to continue
# proxychains iceweasel
################################################################################
###
# 12. Install Filezilla FTP Client (bottom)
###
# 13. Install HTOP and NetHogs (bottom)
### 
# Start and end of 14 - Installing proprietory graphics cards (not used on VMWare)
### 
# 15. Install Recordmydesktop and Reminna Remote Desktop Client (bottom)
###
# 16. Install GDebi Package Manager (bottom)
###
# Start and end of 17. Install a theme (Can't be scripted)
### 
# Start and end of 18. Install a new desktop environment (Can't be scripted)
### 
# Start and end of 19. Enable Autologin user (This is retarded, so I'm not including it)
### 
# Start and end of 20. Unlock GPU processing (not used in VMWare)
### 
################################################################################

################################################################################
### Setup VM tools
apt-get install open-vm-tools-desktop -y
apt-get install open-vm-tools -y

################################################################################

# 8. Install File Roller - Archive Manager
apt-get install unrar unace rar unrar p7zip zip unzip p7zip-full p7zip-rar file-roller -y

# 12. Install Filezilla FTP Client
apt-get install filezilla filezilla-common -y

# 13. Install HTOP and NetHogs
apt-get install htop nethogs -y

# 15. Install Recordmydesktop and Reminna Remote Desktop Client
apt-get install gtk-recordmydesktop recordmydesktop remmina -y

# 16. Install GDebi Package Manager
apt-get install gdebi -y

# Here I want to install some additional software
# Chrome browser
apt-get install chromium -y

#Echo username and password to remember if desired
echo $username $password
# Pause if you want before rebooting
read -p "Script complete.  Press [Enter] key to reboot"

############################# Finally reboot #############################
reboot

#/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\#
#\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/#
################################################################################
# THIS IS ALL CODE THAT IS AVAILABLE FOR HISTORICAL PURPOSES
################################################################################
#apt-get clean -qq && apt-get update -qq && apt-get upgrade -y -qq && apt-get dist-upgrade -y -qq
################################################################################
### EXPANDS {NAME} variable, had to use echo ' instead
################################################################################
#cat << ENDOFAPTREPO >> /usr/sbin/add-apt-repository
#
##!/bin/bash
#
#if [ $# -eq 1 ]
#NM=`uname -a && date`
#NAME=`echo $NM | md5sum | cut -f1 -d" "`
#then
#  ppa_name=`echo "$1" | cut -d":" -f2 -s`
#  if [ -z "$ppa_name" ]
#  then
#    echo "PPA name not found"
#    echo "Utility to add PPA repositories in your debian machine"
#    echo "$0 ppa:user/ppa-name"
#  else
#    echo "$ppa_name"
#    echo "deb http://ppa.launchpad.net/$ppa_name/ubuntu oneiric main" >> /etc/apt/sources.list
#    apt-get update >> /dev/null 2> /tmp/${NAME}_apt_add_key.txt
#    key=`cat /tmp/${NAME}_apt_add_key.txt | cut -d":" -f6 | cut -d" " -f3`
#    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $key
#    rm -rf /tmp/${NAME}_apt_add_key.txt
#  fi
#else
#  echo "Utility to add PPA repositories in your debian machine"
#  echo "$0 ppa:user/ppa-name"
#fi
#
#
#
#
# JAVA UPDATE (PREVIOUS
#curl -L -C - -b "oraclelicense=accept-securebackup-cookie" -O http://download.oracle.com/otn-pub/java/jdk/8u20-b26/jdk-8u20-linux-x64.tar.gz
#
#tar -xzvf /root/jdk-8u20-linux-x64.tar.gz
#mv jdk1.8.0_20 /opt
#cd /opt/jdk1.8.0_20
#
################### Fileneames must be changed here as well ###################
#update-alternatives --install /usr/bin/java java /opt/jdk1.8.0_20/bin/java 1
#update-alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_20/bin/javac 1
#update-alternatives --install /usr/lib/mozilla/plugins/libjavaplugin.so mozilla-javaplugin.so /opt/jdk1.8.0_20/jre/lib/amd64/libnpjp2.so 1
#update-alternatives --set java /opt/jdk1.8.0_20/bin/java
#update-alternatives --set javac /opt/jdk1.8.0_20/bin/javac
#update-alternatives --set mozilla-javaplugin.so /opt/jdk1.8.0_20/jre/lib/amd64/libnpjp2.so
#
#
#ENDOFAPTREPO
########################################
