# Dockerfile Raspberry Pi Nginx
FROM hypriot/rpi-alpine-scratch

RUN apk update && \
	apk add nginx \
	php5-fpm \
	php5-curl \
	php5 \
	php5-json \
	php5-sqlite \
    	php5-curl \
    	php5-common \
    	php-xml-parser \
    	php-apc \
    	ntp \
	supervisor
	
RUN mkdir /data /etc/nginx/sites-available /etc/nginx/sites-enabled /var/www/html

# COPY PHP-FPM Configuration
COPY ./nginx/conf.d/php5-fpm.conf /etc/nginx/conf.d/php5-fpm.conf

# COPY nginx/sites-available/default
COPY ./nginx/sites-available/default /etc/nginx/sites-available/default

# COPY index.php info
COPY ./phpinfo.php /var/www/html/phpinfo.php

# COPY Supervisor
COPY ./etc/supervisord.conf /etc/
COPY ./etc/supervisor.d/agent.ini /etc/supervisor.d/

# Turn off daemon mode
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf

RUN sed -i -e "s/listen \= 127.0.0.1\:9000/listen \= \/var\/run\/php5-fpm.sock/" /etc/php5/fpm/pool.d/www.conf && \
sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf && \
sed -i -e "s/;env/env/g" /etc/php5/fpm/pool.d/www.conf 

# Ports 
EXPOSE 80 443

# Boot up Nginx, and PHP5-FPM when container is started
CMD /usr/bin/supervisord --nodaemon --configuration /etc/supervisord.conf  
