#!/bin/bash


## Update Nginx configs with defaults
echo "Start Nginx Rewrites zzzzz"
cd /var/www/wp-drupalvm/config/defaults/nginx
cp _php_fastcgi.conf /etc/nginx/
rm /etc/nginx/sites-enabled/wp-drupalvm.test.conf
cp wp-drupalvm.test.conf /etc/nginx/sites-enabled/wp-drupalvm.test.conf
/etc/init.d/nginx restart

# Set up a local wp-config that is outside the web root
cd /var/www/wp-drupalvm/web
ln -s ../wp-config.php wp-config.php
cp ../config/wp-config-default.php ../wp-config.php


touch /etc/nginx/sites-enabled/test.test