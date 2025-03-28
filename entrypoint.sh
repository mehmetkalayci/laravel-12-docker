#!/bin/bash

# Stop the script on any errors
set -e

# Wait for the database to be ready before proceeding
echo "⏳ Veritabanı servisi bekleniyor..."
until nc -z -v -w30 $DB_HOST $DB_PORT; do
  echo "Veritabanı bekleniyor ($DB_HOST:$DB_PORT)..."
  sleep 5
done
echo "✅ Veritabanı servisi hazır!"

# Check if APP_KEY is set, if not, generate it
if [ -z "$APP_KEY" ]; then
    echo "APP_KEY tanımlı değil. Oluşturuluyor..."
    php artisan key:generate --force
fi

# Set file permissions for storage and cache directories
echo "Dosya izinleri ayarlanıyor..."
chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache
chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Install Composer dependencies if vendor directory is not present
if [ ! -d "vendor" ]; then
    echo "Composer bağımlılıkları yükleniyor..."
    composer install --no-dev --optimize-autoloader
fi

# Run database migrations if RUN_MIGRATIONS is set to true
echo "Veritabanı migrasyonları çalıştırılıyor..."
php artisan migrate --force

# Clear Laravel caches after migration (since cache depends on database tables)
echo "Cache temizleniyor..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Cache configuration, routes, and views after migrations
echo "Config ve route cache işlemleri yapılıyor..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Finally, run the main command (usually php-fpm)
exec "$@"
