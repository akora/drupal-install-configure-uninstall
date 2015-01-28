
The first script `drupal-install.sh` takes you from a clean LAMP (Debian) environment to a stage where you've got Drupal core installed. The script creates all the necessary configuration files to get you going.

The second script `drupal-configure.sh` is a great companion to the first script. It takes a fresh and clean Drupal install, removes all unnecessary text files and some default themes, checks and installs Drush if not present and makes some initial configuration changes.

The third script `drupal-uninstall.sh` takes you from a fully installed Drupal website and returns you to a stage where you've only got a clean LAMP environment installed. It removes all the artifacts created by the first drupal-install.sh script.

#### Requirements

* Debian Linux, Apache, MySQL, PHP

#### Tested on

* Debian GNU/Linux 6.0.2 (squeeze) with
  * apache2 2.2.16-6+squeeze1
  * mysql-server 5.1.49-3
  * php5 5.3.3-7+squeeze3
  * bash 4.1-3

##### TODO:

* add step for automatic cron job creation
* add support for CentOS

...and yes, I'm aware of drush make... ;)
