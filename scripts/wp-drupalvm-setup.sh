#!/bin/bash
# Set up a local wp-config that is outside the web root

cd /var/www/wp-drupalvm/web
ln -s ../wp-config.php wp-config.php
cp ../config/wp-config-default.php ../wp-config.php

