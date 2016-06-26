# Dockerfile Raspberry Pi Nginx
FROM resin/rpi-raspbian:jessie

# Update sources && install packages
RUN DEBIAN_FRONTEND=noninteractive ;\
apt-get update && \
apt-get install --assume-yes \
	nginx \
	php5-fpm \
	ntp

# ADD PHP-FPM Configuration
ADD ./nginx/conf.d/php5-fpm.conf /etc/nginx/conf.d/php5-fpm.conf

# ADD nginx/sites-available/default
ADD ./nginx/sites-available/default /etc/nginx/sites-available/default

# ADD index.php info
ADD ./index.php /var/www/html/index.php

# Turn off daemon mode
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf

RUN sed -i -e 's/listen \= 127.0.0.1\:9000/listen \= \/var\/run\/php5-fpm.sock/' /etc/php5/fpm/pool.d/www.conf
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf

RUN echo "Europe/Paris" > /etc/timezone && dpkg-reconfigure tzdata && sed -i 's/.debian./.fr./g' /etc/ntp.conf

# Volume
VOLUME ["/etc/nginx", "/etc/nginx/conf.d", "/var/www/html"]

# Set the current working directory
WORKDIR /var/www/html

# Ports 
EXPOSE 80 443

# Boot up Nginx, and PHP5-FPM when container is started
CMD service php5-fpm start && nginx