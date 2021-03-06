FROM php:5.6-apache
LABEL maintainer="Saroj Sangphongamphai <ss.saroj@gmail.com>"

ENV PS_DOMAIN="localhost" \
DB_SERVER="localhost" \
DB_PORT=3306 \
DB_NAME=prestashop \
DB_USER=root \
DB_PASSWD=admin \
DB_PREFIX=ps_ \
ADMIN_MAIL=demo@prestashop.com \
ADMIN_PASSWD=prestashop_demo \
PS_LANGUAGE=en \
PS_COUNTRY=gb \
PS_INSTALL_AUTO=0 \
PS_ERASE_DB=0 \
PS_DEV_MODE=0 \
PS_HOST_MODE=0 \
PS_HANDLE_DYNAMIC_DOMAIN=0 \
PS_FOLDER_ADMIN=admin \
PS_FOLDER_INSTALL=install \
DEBIAN_FRONTEND=noninteractive

RUN echo "mysql-server mysql-server/root_password password admin" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password admin" | debconf-set-selections

RUN apt-get update

RUN apt-get install -y mysql-server

RUN apt-get install -y libmcrypt-dev \
		libjpeg62-turbo-dev \
		libpcre3-dev \
		libpng12-dev \
		libfreetype6-dev \
		libxml2-dev \
		libicu-dev \
		mysql-client \
		wget \
		unzip \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install iconv intl mcrypt pdo pdo_mysql mbstring soap gd zip

RUN docker-php-source extract \
	&& if [ -d "/usr/src/php/ext/mysql" ]; then docker-php-ext-install mysql; fi \
	&& if [ -d "/usr/src/php/ext/opcache" ]; then docker-php-ext-install opcache; fi \
	&& docker-php-source delete

ENV PS_VERSION 1.7.2.4

# Get PrestaShop
ADD prestashop_1.7.2.4.zip /tmp/prestashop.zip

# Prepare install and CMD script
COPY config_files/ps-extractor.sh config_files/docker_run.sh /tmp/

# Extract
RUN mkdir -p /tmp/data-ps /var/www/modules /var/www/themes /var/www/override \
	&& unzip -q /tmp/prestashop.zip -d /tmp/data-ps/ \
	&& bash /tmp/ps-extractor.sh /tmp/data-ps \
	&& rm /tmp/prestashop.zip
COPY config_files/docker_updt_ps_domains.php /var/www/html/

# Apache configuration
RUN a2enmod rewrite

# PHP configuration
COPY config_files/php.ini /usr/local/etc/php/

# MySQL configuration
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
EXPOSE 3306

# Run
CMD ["/tmp/docker_run.sh"]
