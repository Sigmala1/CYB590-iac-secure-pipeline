FROM php:8.4-apache

# Copy the application code
COPY . /var/www/html/

# Apache configurations
RUN a2enmod rewrite

# Set correct permissions
RUN chown -R www-data:www-data /var/www/html

# Expose port 80
EXPOSE 80

# Start Apache in foreground
CMD ["apache2-foreground"]
