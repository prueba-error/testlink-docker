FROM php:7.4-apache

# Use Debian archive repositories for Bullseye
RUN echo "deb http://archive.debian.org/debian bullseye main" > /etc/apt/sources.list \
    && echo "deb http://archive.debian.org/debian-security bullseye-security main" >> /etc/apt/sources.list

# Install required system packages and PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    default-mysql-client \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    curl \
    tar \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd mysqli zip

# Configure recommended PHP runtime settings for TestLink
RUN { \
    echo 'max_execution_time = 300'; \
    echo 'memory_limit = 256M'; \
    echo 'post_max_size = 64M'; \
    echo 'upload_max_filesize = 64M'; \
    echo 'session.gc_maxlifetime = 7200'; \
    echo 'date.timezone = UTC'; \
} > /usr/local/etc/php/conf.d/testlink.ini

# Download and extract TestLink 1.9.20 source code
ENV TESTLINK_VERSION=testlink_1_9_20_fixed
RUN curl -fsSL "https://github.com/TestLinkOpenSourceTRMS/testlink-code/archive/refs/heads/${TESTLINK_VERSION}.tar.gz" -o /tmp/testlink.tar.gz \
    && tar -xzf /tmp/testlink.tar.gz --strip-components=1 -C /var/www/html \
    && rm /tmp/testlink.tar.gz

# Prepare directories for uploads, logs, and set permissions
RUN mkdir -p /var/testlink/upload_area /var/testlink/logs \
    && chown -R www-data:www-data /var/www/html /var/testlink \
    && chmod -R 775 /var/testlink

# Copy entrypoint script and normalize line endings for Linux
COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
