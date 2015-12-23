#!/usr/bin/env bash
# Clear The Old Environment Variables

sed -i '/# Set Mockingj Environment Variable/,+1d' /home/vagrant/.profile
sed -i '/env\[.*/,+1d' /etc/php-fpm/php-fpm.conf
