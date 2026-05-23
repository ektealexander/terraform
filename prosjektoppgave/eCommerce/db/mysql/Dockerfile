# MySQL 8 + rasdr/eCommerce sample DB (tverr / bedrift / Passord123)
# Build from repo root: docker build -f db/mysql/Dockerfile .
FROM mysql:8.0
COPY db/dump/ecom3.sql /docker-entrypoint-initdb.d/01-ecom3.sql
