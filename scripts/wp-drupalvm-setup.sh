#!/bin/bash

rootDir='/var/www';
hostname='wp-drupalvm'
localConfig=false;
#localConfigFile='/var/www/$hostname/config/local.config.yml';
nginxDir='/etc/nginx';
nginxConfigDir=$nginxDir'/sites-enabled'


echo "-------------------------"
echo " Begin WP-DRUPALVM Setup"
echo "-------------------------"

# Find local config file, if it exists
localConfigFile=( $(find $rootDir -name "local.config.yml") )

# Include config-parse.sh
. $rootDir/$hostname/scripts/config-parse.sh

if [ -f $localConfigFile ];
then

    localConfig=true;
    echo -e "\n==>Local config file found"

    # Read the yaml file
    eval $(parse_yaml $localConfigFile "config_")

    # Set hostname
    hostname=$config_vagrant_hostname

    # Reset Local Config File location
    localConfigFile='/var/www/$hostname/config/local.config.yml';

else
    echo -e "\n==>No local config file. Using wp-drupalvm defaults"
fi


echo "---------------------------------";
echo $hostname
echo "---------------------------------";
## Update Nginx configs with defaults
echo -e"\n==> Start Nginx Rewrites"
cd $rootDir/$hostname/config/defaults/nginx

## Copy nginx config stub
echo -e "\n==> Copy _php_fastcgi.conf to nginx directory"
cp _php_fastcgi.conf $nginxDir

# Remove the wp-drupalvm nginx config
echo -e "\n==> Remove drupalvm nginx conf"
rm $nginxConfigDir/wp-drupalvm.test.conf

# Add new config file
echo -e "\n==> Replace nginx configuration file"
cp wp-drupalvm.test.conf $nginxConfigDir/$hostname.conf

# If a local config file exists, rewrite values
if $localConfig;
then
    echo -e "\n==> Updating nginx configuration"
    sed -i 's/wp-drupalvm/${hostname}/g' $nginxConfigDir/wp-drupalvm.test.conf
fi

echo -e "\n==> Restarting nginx"
/etc/init.d/nginx restart


# Set up a local wp-config that is outside the web root
echo -e "\n==> Add symlink to wp-config"
cd $rootDir/$hostname/web

echo -e "\n==> Create symlink to wp-config.php"
ln -s $rootDir/$hostname/web/wp-config.php wp-config.php

echo -e "\n==> Write contents of wp-config.php"
cp $rootDir/$hostname/web/config/wp-config-default.php $rootDir/$hostname/wp-config.php

echo -e "\n==> Update wp-config.php"

echo -e "\nwp-drupalvm setup complete"