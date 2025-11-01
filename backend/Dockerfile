FROM php:8.3-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    postgresql-client \
    libpq-dev \
    && docker-php-ext-install pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy composer files
COPY composer.json ./

# Install dependencies without running scripts (artisan belum ada)
RUN composer install --no-dev --optimize-autoloader --no-scripts || composer install --optimize-autoloader --no-scripts

# Copy application files
COPY . .

# Run post-install scripts after files are copied
RUN composer dump-autoload --optimize --no-dev || composer dump-autoload --optimize

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage

EXPOSE 8000

CMD php artisan serve --host=0.0.0.0 --port=8000

