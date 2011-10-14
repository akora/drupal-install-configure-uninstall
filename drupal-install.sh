#!/usr/bin/env bash

#===========================================================================
#
#          FILE: drupal-install.sh
#
#         USAGE: 1. chmod ugo+x drupal-install.sh
#                2. edit this file and specify the MySQL user details below
#                3. sudo ./drupal-install.sh [sitename] [Drupal version]
#
#   DESCRIPTION: This script takes you from a clean LAMP environment to
#                a stage where you've got Drupal core installed. The script
#                creates all the necessary configuration files to get you
#                going.
#
#       OPTIONS: You have to provide the site name and the Drupal version
#  REQUIREMENTS: Debian linux, Apache, MySQL, PHP
#          BUGS: no major known bugs so far
#
#         NOTES: Tested on Debian GNU/Linux 6.0.2 (squeeze)
#                          apache2 2.2.16-6+squeeze1
#                          mysql-server 5.1.49-3
#                          php5 5.3.3-7+squeeze3
#                          bash 4.1-3
#
#          TODO: add step for automatic cron job creation
#          TODO: add support for CentOS
#
#       VERSION: v0.1
#       CREATED: 2011-10-14
#      REVISION: initial version
#
#        AUTHOR: Andras Kora
#         EMAIL: ak@akora.info
#       WEBSITE: http://akora.info
#
#===========================================================================

# default configuration settings

sitename="$1"
webroot="/var/www"

drupal_version="$2"
drupal_download_filename="drupal-$drupal_version.tar.gz"
drupal_directory_name="drupal-$drupal_version"
drupal_download_url="http://ftp.drupal.org/files/projects/$drupal_download_filename"
drupal_local_copy_path="/home/$SUDO_USER/drupal/core"

# specify MySQL access details

db_user=""
db_pass=""

# managing messages

function message_same_line () {
  msg=$1
  param=$2
  printf "%-50s %s" "=== $msg" $param
}

function message_new_line () {
  msg=$1
  param=$2
  printf "%-50s %s\n" "=== $msg" $param
}

function message_response () {
  msg=$1
  # printf "%-10s %s\n" "[ $msg ]"
  printf "%-10s %s\n" "$msg"
}

# main functions

function get_site_name () {
  if [ $# -ne 2 ]; then
    message_new_line "Usage: $0 [sitename] [Drupal core version] (e.g. d6 6.22)"
    exit 0
  else
    message_new_line "Building the website" $1
  fi
}

function get_drupal_core () {

  message_same_line "Checking local directory structure..."
  if [ -d $drupal_local_copy_path ]; then
    message_response "download directory present"
  else
    message_response "creating download directory..."
      mkdir -p $drupal_local_copy_path
  fi

  message_same_line "Checking Drupal core package..."
  if [ -f $drupal_local_copy_path/$drupal_download_filename ]; then
    message_response "Drupal core present"
  else
    message_response "downloading core..."
      cd $drupal_local_copy_path
      wget $drupal_download_url
  fi

  message_same_line "Checking Drupal core files..."
  if [ -d $drupal_local_copy_path/$drupal_directory_name ]; then
    message_response "files already extracted"
  else
    message_response "extracting..."
      cd $drupal_local_copy_path
      tar -xzf $drupal_local_copy_path/$drupal_download_filename
      chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/drupal
  fi

}

function set_up_drupal () {

  message_same_line "Moving Drupal core to webroot..."
  if [ -d $webroot/$sitename ]; then
    message_response "webroot already exists"
  else
    message_response "creating webroot..."
      cp -r $drupal_local_copy_path/$drupal_directory_name $webroot
      mv $webroot/$drupal_directory_name $webroot/$sitename
  fi

  message_same_line "Checking settings.php file..."
  if [ -f $webroot/$sitename/sites/default/settings.php ]; then
    message_response "settings.php already exists"
  else
    message_response "creating settings.php..."
      cp $webroot/$sitename/sites/default/default.settings.php $webroot/$sitename/sites/default/settings.php
      chmod 777 $webroot/$sitename/sites/default/settings.php
  fi

  message_same_line "Checking /files directory..."
  if [ -d $webroot/$sitename/sites/default/files ]; then
    message_response "/files directory already exists"
  else
    message_response "creating /files directory..."
      mkdir $webroot/$sitename/sites/default/files
      chmod 777 $webroot/$sitename/sites/default/files
  fi

  message_same_line "Checking the MySQL database..."
  if [ -d /var/lib/mysql/$sitename ]; then
    message_response "database already exists"
  else
    message_response "creating database..."
      /usr/bin/mysqladmin --user=$db_user --password=$db_pass create $sitename
  fi

  message_same_line "Checking the Apache vhost file..."
  if [ -f /etc/apache2/sites-available/$sitename ]; then
    message_response "vhost file already exists"
  else
    message_response "creating the vhost file..."
      touch $sitename
      echo "<VirtualHost *:80>" >> $sitename
      echo "  ServerAdmin "$USER"@localhost" >> $sitename
      echo "  ServerName "$sitename >> $sitename
      echo "  ServerAlias "$sitename >> $sitename
      echo "  DocumentRoot \"$webroot/$sitename\"" >> $sitename
      echo "  LogLevel warn" >> $sitename
      echo "  <Directory \"$webroot/$sitename\">" >> $sitename
      echo "    Options +Indexes" >> $sitename
      echo "    AllowOverride All" >> $sitename
      echo "    Allow from all" >> $sitename
      echo "  </Directory>" >> $sitename
      echo "  ErrorLog /var/log/apache2/"$sitename"-error.log" >> $sitename
      echo "  CustomLog /var/log/apache2/"$sitename"-access.log combined" >> $sitename
      echo "</VirtualHost>" >> $sitename
    mv $sitename /etc/apache2/sites-available/
  fi

  message_same_line "Checking if the website is enabled..."
  if [ -L /etc/apache2/sites-enabled/$sitename ]; then
    message_response "website is already enabled"
  else
    message_response "enabling website..."
      /usr/sbin/a2ensite $sitename
      /etc/init.d/apache2 reload
  fi

  message_same_line "Adding entry to /etc/hosts..."
  if grep -Fxq "127.0.0.1 $sitename" /etc/hosts; then
    message_response "entry is already present"
  else
    message_response "adding new entry..."
      echo "127.0.0.1 $sitename" >> /etc/hosts
  fi

}

# main script control flow

get_site_name $1 $2
get_drupal_core
set_up_drupal

message_new_line "Visit http://$sitename and continue with the installation..."
message_new_line "Run the following command: sudo chmod 755 $webroot/$sitename/sites/default/settings.php"

# All done

exit 0