FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libicu-dev \
    libxslt1-dev \
    libsodium-dev \
    cron \
    vim \
    libwebp-dev \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions required by Magento 2
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
    bcmath \
    gd \
    intl \
    mysqli \
    opcache \
    pdo_mysql \
    soap \
    sockets \
    xsl \
    zip \
    sodium

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Install Node.js and npm (for frontend build tools)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Set working directory
WORKDIR /var/www/html

# Create Magento user
RUN groupadd -g 1000 magento \
    && useradd -u 1000 -g magento -m -s /bin/bash magento

# Configure PHP-FPM to run as magento user
RUN sed -i 's/user = www-data/user = magento/g' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/group = www-data/group = magento/g' /usr/local/etc/php-fpm.d/www.conf

# Set permissions
RUN chown -R magento:magento /var/www/html

# Expose port 9000
EXPOSE 9000

CMD ["php-fpm"]
