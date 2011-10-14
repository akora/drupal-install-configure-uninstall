#!/usr/bin/env bash

#===========================================================================
#
#          FILE: drupal-uninstall.sh
#
#         USAGE: 1. chmod ugo+x drupal-uninstall.sh
#                2. edit this file and specify the MySQL user details below
#                3. sudo ./drupal-uninstall [sitename]
#
#   DESCRIPTION: This script takes you from a fully installed Drupal website
#                and returns you to a stage where you've only got a clean
#                LAMP environment installed. It removes all the artifacts
#                created by the drupal-install.sh script.
#
#       OPTIONS: You have to provide the name of the site you want to remove
#  REQUIREMENTS: Debian linux, Apache, MySQL, PHP
#          BUGS: no major known bugs so far
#
#         NOTES: Tested on Debian GNU/Linux 6.0.2 (squeeze)
#                          apache2 2.2.16-6+squeeze1
#                          mysql-server 5.1.49-3
#                          php5 5.3.3-7+squeeze3
#                          bash 4.1-3
#
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
  if [ $# -ne 1 ]; then
    message_new_line "Usage: $0 [sitename] (e.g. d6)"
    exit 0
  else
    message_new_line "Removing the website" $1
  fi
}

function remove_drupal_site () {

  message_same_line "Checking if website exists..."
  if [ -d $webroot/$sitename ]; then
    message_response "website exists... removing it..."
      rm -rf $webroot/$sitename
  else
    message_response "website does NOT exist!"
  fi

  message_same_line "Checking the MySQL database..."
  if [ -d /var/lib/mysql/$sitename ]; then
    message_response "database exists... removing it..."
      # need -f to force MySQL and not let it ask "Are you sure...?"
      /usr/bin/mysqladmin -u $db_user -p$db_pass -f drop $sitename
  else
    message_response "database does NOT exist!"
  fi

  message_same_line "Checking the Apache vhost file..."
  if [ -f /etc/apache2/sites-enabled/$sitename ]; then
    message_response "site is enabled... disabling it..."
      /usr/sbin/a2dissite $sitename
      /etc/init.d/apache2 reload
      # removing the initial file as well
      rm /etc/apache2/sites-available/$sitename
      # removing log files
      rm /var/log/apache2/$sitename-access.log
      rm /var/log/apache2/$sitename-error.log
  else
    message_response "vhost file does NOT exist!"
  fi

  message_same_line "Checking entry in /etc/hosts..."
  if grep -Fxq "127.0.0.1 $sitename" /etc/hosts; then
    message_response "entry is present... removing it..."
      # need to make the change permanent
      sed "/127.0.0.1 $sitename/d" /etc/hosts > tmp
      mv tmp /etc/hosts
  else
    message_response "entry does NOT exist!"
  fi

}

# main script control flow

get_site_name $1
remove_drupal_site

message_new_line "All done... $sitename removed."

# All done.

exit 0