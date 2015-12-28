# Mockingj

Simplified and customized [Laravel/Homestead](https://github.com/laravel/homestead) for [CentOS 7](https://www.centos.org) in VirtualBox environment.

A php composer package partially integrate with **vagrant** with easy-customisable box configuration.


## Includes

* VirtualBox Guest Additions (v5.0.12)
* Nginx (Mainline)
* MariaDB 10.1
  * Username: mockingj
  * Password: secret
* Postgresql 9.4
* Sqlite 3.7
* PHP 7.0.1
* Xdebug
* Composer
  * Composer Path: /usr/local/bin/composer
  * Vendor Path: ~/.composer/vendor/bin
* Git 2.6.3
* NodeJS v5


## Installation

1) Add vagrant box

```bash
vagrant box add justinmoh/mockingj
```

2) Get `mockingj` with composer

```bash
composer global require justinmoh/mockingj
```

3) Init the application

```bash
cd ~/.composer/vendor/justinmoh/mockingj/ && sh init.sh
```

4) Accessing Mockingj globally

```
echo 'alias mockingj="function __mockingj() { (cd ~/.composer/vendor/justinmoh/mockingj && vagrant \$*); unset -f __mockingj; }; __mockingj"' >> ~/.bash_profile
```

5) Configure

```bash
open ~/.mockingj/mockingj.yaml
```

6) Edit `/etc/hosts` in host (local) machine and add the following:

> 192.168.20.20     mockingj.dev

7) UP!

```bash
mockingj up
```



## Default Forwarded IP and Ports

```
ip: "192.168.20.20"
```

```
default_ports = {
  80   => 8001,
  443  => 44301,
  3306 => 33061,
  5432 => 54321
}
```

## Vagrant Boxes

### Based On
* [CentOS/7 (v1509.1)](https://atlas.hashicorp.com/centos/boxes/7/versions/1509.01)

### Extended VM required
* [justinmoh/mockingj](https://atlas.hashicorp.com/justinmoh/mockingj)

