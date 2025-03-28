# En güncel PHP FPM imajını kullan
FROM php:8.2-fpm

WORKDIR /var/www

# Gerekli bağımlılıkları ve PHP uzantılarını yükle
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev \
    zip unzip git curl libonig-dev libzip-dev \
    netcat-openbsd \
    && docker-php-ext-install pdo_mysql mbstring zip exif pcntl \
    && rm -rf /var/lib/apt/lists/*

# En güncel Composer imajından composer'ı kopyala
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Uygulama dosyalarını kopyala
COPY . .

# Giriş script'ini kopyala ve çalıştırılabilir yap
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Container başlatıldığında giriş script'ini çalıştır
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["php-fpm"]
