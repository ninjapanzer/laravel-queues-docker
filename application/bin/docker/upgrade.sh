#!/bin/bash
echo "HI"

source /etc/environment

/bin/rm -rf /var/www/default/*

/bin/rm -rf /var/www/default/.[^.] /var/www/default/.??*

/bin/cp -rf /var/app/. /var/www/default

cd /var/www/default

/usr/bin/composer install

yarn install

php artisan migrate
