# eCommerce (Azure overrides)

Azure-specific files for [rasdr/eCommerce](https://github.com/rasdr/eCommerce). Run `..\scripts\setup-ecommerce.ps1` once to pull in the rest of the upstream repo (only missing paths).

## Committed overrides

| Path | Purpose |
|------|---------|
| `Dockerfile` | Python 3.12, mysql client, `docker-entrypoint.sh` |
| `docker-entrypoint.sh` | Wait for MySQL, import `ecom3.sql` if empty, gunicorn |
| `requirements.txt` | `dj-database-url`, `whitenoise`, `gunicorn`, etc. |
| `db/mysql/Dockerfile` | MySQL 8 image with sample DB init |
| `eCommerce/settings.py` | Env-based `SECRET_KEY`, `ALLOWED_HOSTS`, `DATABASE_URL` |
| `eCommerce/urls.py` | URL routing |
| `store/*`, `templates/store/*` | Store, auth, UI |

Align `mysql_*` in `terraform.tfvars` with `db/dump/ecom3.sql` after setup.
