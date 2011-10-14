#!/usr/bin/env bash

#===========================================================================
#
#          FILE: drupal-configure.sh
#
#         USAGE: 1. chmod ugo+x drupal-configure.sh
#                2. sudo ./drupal-configure.sh [sitename]
#
#   DESCRIPTION: This script takes a fresh and clean Drupal install, removes
#                all unnecessary text files and some default themes, checks
#                and installs Drush if not present and makes some initial 
#                configuration changes.
#
#       OPTIONS: You have to provide the site name
#  REQUIREMENTS: Debian linux, Apache, MySQL, PHP
#          BUGS: no major known bugs so far
#
#         NOTES: Tested on Debian GNU/Linux 6.0.2 (squeeze)
#                          apache2 2.2.16-6+squeeze1
#                          mysql-server 5.1.49-3
#                          php5 5.3.3-7+squeeze3
#                          bash 4.1-3
#                    using drush 7.x-4.5
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

drush_version="7.x-4.5"
drush_download_filename="drush-$drush_version.tar.gz"
drush_download_url="http://ftp.drupal.org/files/projects/$drush_download_filename"

text_files=( CHANGELOG.txt COPYRIGHT.txt INSTALL.mysql.txt INSTALL.pgsql.txt 
            INSTALL.txt LICENSE.txt MAINTAINERS.txt UPGRADE.txt )
themes=( bluemarine chameleon pushbutton )
directories=( modules themes )

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
  printf "%-10s %s\n" "    $msg"
}

# main functions

function get_site_name () {

  if [ $# -ne 1 ]; then
    message_new_line "Usage: $0 [sitename] (e.g. d6)"
    exit 0
  else
    message_new_line "Configuring the website" $1
  fi

}

function clean_up_files () {

  message_new_line "Removing unnecessary files..."
  for file_to_remove in ${text_files[@]}; do
    if [ -f $webroot/$sitename/$file_to_remove ]; then
      rm $webroot/$sitename/$file_to_remove
    else
      message_response "$webroot/$sitename/$file_to_remove removed..."
    fi
  done

}

function clean_up_themes () {

  message_new_line "Removing unnecessary themes..."
  for theme_to_remove in ${themes[@]}; do
    if [ -d $webroot/$sitename/themes/$theme_to_remove ]; then
      rm -rf $webroot/$sitename/themes/$theme_to_remove
    else
      message_response "$webroot/$sitename/themes/$theme_to_remove removed..."
    fi
  done

}

function create_directories () {

  message_new_line "Creating site specific /modules and /themes directories..."
  for dir_to_create in ${directories[@]}; do
    if [ -d $webroot/$sitename/sites/all/$dir_to_create ]; then
      message_response "$webroot/$sitename/sites/all/$dir_to_create already present..."
    else
      mkdir $webroot/$sitename/sites/all/$dir_to_create
    fi
  done

}

function install_drush () {

  message_same_line "Checking if Drush is installed..."
  if [ -d /home/$SUDO_USER/drush ]; then
    message_response "Drush present"
  else
    message_response "installing drush..."
      cd /home/$SUDO_USER
      wget $drush_download_url
      tar -xzf $drush_download_filename
      chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/drush
      rm $drush_download_filename
      ln -s /home/$SUDO_USER/drush/drush /usr/local/bin/drush
  fi

}

function test_drush () {

  message_new_line "Testing Drush..."
  cd $webroot/$sitename
  drush status

}

function configure_website () {

  message_new_line "Configuring the website..."

  # add more Drush magic here...
  drush -y en path
  drush -y en php
  drush -y en statistics
  drush -y en syslog
  drush -y en upload

  # setting the default theme Garland
  drush vset --always-set theme_default garland 1
  drush vset --always-set admin_theme garland 1

  # run cron
  drush cron

}

# main script control flow

get_site_name $1
clean_up_files
clean_up_themes
create_directories
install_drush
test_drush
configure_website

# All done.

exit 0