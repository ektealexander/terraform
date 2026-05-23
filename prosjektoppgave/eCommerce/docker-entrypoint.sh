#!/bin/bash
set -e

wait_for_mysql() {
  echo "Waiting for MySQL..."
  for _ in $(seq 1 90); do
    if mysqladmin ping -h 127.0.0.1 -uroot -p"${MYSQL_ROOT_PASSWORD}" --silent 2>/dev/null; then
      return 0
    fi
    sleep 2
  done
  echo "MySQL did not become ready in time."
  return 1
}

import_sample_db() {
  if mysql -h 127.0.0.1 -uroot -p"${MYSQL_ROOT_PASSWORD}" tverr -e "SELECT 1 FROM store_product LIMIT 1" 2>/dev/null; then
    echo "Database tverr already contains sample data."
    return 0
  fi
  echo "Importing db/dump/ecom3.sql..."
  mysql -h 127.0.0.1 -uroot -p"${MYSQL_ROOT_PASSWORD}" < /app/db/dump/ecom3.sql
}

wait_for_mysql
import_sample_db

python manage.py collectstatic --noinput
python manage.py migrate --noinput
exec gunicorn --bind 0.0.0.0:8000 --workers 3 eCommerce.wsgi:application
