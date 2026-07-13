FROM php:8.2-fpm-alpine

RUN apk add --no-cache \
    nginx nodejs npm curl git zip unzip \
    libpng-dev libjpeg-dev libzip-dev oniguruma-dev

RUN docker-php-ext-install \
    pdo_mysql mbstring zip gd bcmath opcache

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app

COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-scripts

COPY . .

RUN composer run-script post-autoload-dump

RUN npm ci && npm run build && rm -rf node_modules

RUN chown -R www-data:www-data /app/storage /app/bootstrap/cache

COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80
CMD ["/start.sh"]