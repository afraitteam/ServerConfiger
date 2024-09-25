#!/bin/bash

# بررسی وجود رمز عبور به عنوان پارامتر ورودی
DB_PASSWORD=$1

if [ -z "$DB_PASSWORD" ]; then
  echo "Error: No password provided. Usage: ./install.sh <db_password>"
  exit 1
fi

# به‌روزرسانی و ارتقاء سیستم
sudo apt update -y
sudo apt upgrade -yf

# نصب بسته‌های مورد نیاز
sudo apt install -y curl gpg gnupg2 software-properties-common ca-certificates apt-transport-https lsb-release

# اضافه کردن مخزن PHP
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update -y

# نصب PHP 8.3 و PHP 7.4 با ماژول‌های مورد نیاز
sudo apt install php-{cli,fpm,mysql,zip,gd,mbstring,curl,xml,bcmath,common,soap,xml,xmlrpc} -y
sudo apt install php7.4-{cli,fpm,mysql,zip,gd,mbstring,curl,xml,bcmath,common,soap,xml,xmlrpc} -y

# نصب MariaDB و Redis
sudo apt install -y mariadb-server redis-server

# تنظیم رمز عبور برای کاربر root در MariaDB
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';"
sudo mysql -e "FLUSH PRIVILEGES;"

# امن‌سازی MariaDB
sudo mysql -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -e "DROP DATABASE IF EXISTS test;"
sudo mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';"
sudo mysql -e "FLUSH PRIVILEGES;"

# تنظیمات debconf برای phpMyAdmin (بدون تعامل)
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password ${DB_PASSWORD}" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password ${DB_PASSWORD}" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password ${DB_PASSWORD}" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect nginx" | sudo debconf-set-selections

# نصب phpMyAdmin بدون درخواست پیکربندی دستی
sudo DEBIAN_FRONTEND=noninteractive apt install -y phpmyadmin

# ایجاد شورتکات phpMyAdmin
sudo ln -s /usr/share/phpmyadmin /var/www/html/pma

# نصب Composer
sudo apt install -y composer

# نصب Certbot و افزونه Nginx
sudo apt install -y certbot python3-certbot-nginx

# تغییر DNS سرورها
echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" | sudo tee /etc/resolv.conf > /dev/null

# پیام تکمیل
echo "Installation and configuration complete."
