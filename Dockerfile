################################################################################
# Base image
################################################################################

FROM nginx

################################################################################
# Build instructions
################################################################################

RUN apt-get update && apt-get install -my \
  supervisor \
  curl \
  wget

RUN echo 'deb http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list
RUN echo 'deb-src http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list

RUN wget https://www.dotdeb.org/dotdeb.gpg && apt-key add dotdeb.gpg

# Remove default nginx configs.
RUN rm -f /etc/nginx/conf.d/*

# Install packages
RUN apt-get update && apt-get install -my \
  php7.0-curl \
  php7.0-fpm \
  php7.0-gd \
  php7.0-memcached \
  php7.0-mysql \
  php7.0-mcrypt \
  php7.0-mbstring \
  php7.0-sqlite \
  php-apc \
  libx11-dev \
  libxext6 \
  libxrender1 \
  zlib1g \
  fontconfig \
  libfreetype6

# Ensure that PHP7 FPM is run as root.
RUN sed -i "s/user = www-data/user = root/" /etc/php/7.0/fpm/pool.d/www.conf
RUN sed -i "s/group = www-data/group = root/" /etc/php/7.0/fpm/pool.d/www.conf

# Pass all docker environment
RUN sed -i '/^;clear_env = no/s/^;//' /etc/php/7.0/fpm/pool.d/www.conf

# Get access to FPM-ping page /ping
RUN sed -i '/^;ping\.path/s/^;//' /etc/php/7.0/fpm/pool.d/www.conf
# Get access to FPM_Status page /status
RUN sed -i '/^;pm\.status_path/s/^;//' /etc/php/7.0/fpm/pool.d/www.conf

# Install HHVM
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
RUN echo deb http://dl.hhvm.com/debian jessie main | tee /etc/apt/sources.list.d/hhvm.list
RUN apt-get update && apt-get install -y hhvm

# Add configuration files
COPY conf/nginx.conf /etc/nginx/
COPY conf/supervisord.conf /etc/supervisor/conf.d/
COPY conf/php.ini /etc/php/7.0/fpm/conf.d/40-custom.ini


################################################################################
# SSL
################################################################################

RUN mkdir -p /var/nginx/certs

RUN openssl req \
    -x509 \
    -newkey rsa:4096 \
    -days 365 \
    -nodes \
    -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.savvysoftworks.com" \
    -keyout /var/nginx/certs/default.key \
    -out /var/nginx/certs/default.cert

RUN chmod 400 /var/nginx/certs/default.key

################################################################################
# Volumes
################################################################################

VOLUME ["/var/www", "/etc/nginx/conf.d", "/var/nginx/certs"]

################################################################################
# Ports
################################################################################

EXPOSE 80 443 9000

################################################################################
# Entrypoint
################################################################################

ENTRYPOINT ["/usr/bin/supervisord"]
