#!/usr/bin/env bash
# Initial setup after insert GuestAdditions.iso in a fresh centos/7 image.

sudo yum install epel-release && \
 sudo yum upgrade && \
 sudo yum install install gcc kernel-devel kernel-headers dkms make bzip2 perl


echo "# Nginx Pre-Built Packages for Mainline version
# http://nginx.org/en/linux_packages.html
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/7/\$basearch/
gpgcheck=0
enabled=1" | sudo tee /etc/yum.repos.d/nginx.repo