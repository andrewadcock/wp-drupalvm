#!/bin/bash

rootDir='/var/www'
hostname='wp-drupalvm'
localConfig=false;
#localConfigFile='/var/www/$hostname/config/local.config.yml';
nginxDir='/etc/nginx'
nginxConfigDir=$nginxDir'/sites-enabled'

#sudo touch $rootDir/farts.test/begin.test
#echo "-------------------------"
#echo " Begin WP-DRUPALVM Setup"
#echo "-------------------------"

# Find local config file, if it exists
localConfigFile=( $(find $rootDir -name "local.config.yml") )

# Include config-parse.sh
#sudo . $(dirname $0)/config-parse.sh
# Thanks to ravibhure - https://gist.github.com/ravibhure/7c5145ab6ea2906ddea0

parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

if [ -f $localConfigFile ];
then

    localConfig=true
#    echo -e "\n==>Local config file found"

    # Read the yaml file
    eval $(parse_yaml $localConfigFile "config_")

    # Set hostname
    hostname=$config_vagrant_hostname

    # Reset Local Config File location
    localConfigFile='/var/www/$hostname/config/local.config.yml';

#else
#    echo -e "\n==>No local config file. Using wp-drupalvm defaults"
fi

## Update Nginx configs with defaults
#echo -e "\n==> Start Nginx Rewrites"

## Copy nginx config stub
#echo -e "\n==> Copy _php_fastcgi.conf to nginx directory"
sudo cp $rootDir/$hostname/config/defaults/nginx/_php_fastcgi.conf $nginxDir

# Remove the wp-drupalvm nginx config
#echo -e "\n==> Remove drupalvm nginx conf"
#rm $nginxConfigDir/wp-drupalvm.test.conf

# Add new config file
#echo -e "\n==> Replace nginx configuration file"
sudo cp wp-drupalvm.test.conf $nginxConfigDir/$hostname.conf

# If a local config file exists, rewrite values
if $localConfig;
then
#    echo -e "\n==> Updating nginx configuration"
    sudo sed -i "s/wp-drupalvm.test/$hostname/g" $nginxConfigDir/$hostname.conf
    sudo sed -i "s/wp-drupalvm/$hostname/g" $nginxConfigDir/$hostname.conf
    #sed -i 's/wp-drupalvm/bacon/g' $nginxConfigDir/$hostname.conf
fi

# Set up a local wp-config that is outside the web root
#echo -e "\n==> Add symlink to wp-config"

#echo -e "\n==> Create symlink to wp-config.php"
sudo ln -s $rootDir/$hostname/wp-config.php $rootDir/$hostname/web/wp-config.php

#echo -e "\n==> Write contents of wp-config.php"
sudo cp $rootDir/$hostname/config/wp-config-default.php $rootDir/$hostname/wp-config.php

#echo -e "\n==> Update wp-config.php"
#echo -e "\nwp-drupalvm setup complete"