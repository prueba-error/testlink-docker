# TestLink Docker Deployment

A clean, reproducible, and zero-touch Docker Compose setup for **TestLink 1.9.20** with **MariaDB 10.11**.

## Features

- **Automated First-Run Initialization**: Automatically seeds the database schema and default dataset on initial container startup, removing the need to click through manual web installers.
- **Independent & Reproducible**: Builds directly from official TestLink source code without relying on deprecated or paywalled third-party images (such as legacy Bitnami images).
- **Optimized for Compatibility**: Pre-configured with PHP extensions (`gd`, `mysqli`, `zip`) and relaxed SQL modes (`ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION`) tailored for TestLink.
- **Persistent Data**: Preserves database tables, uploaded test case attachments, and application logs using named Docker volumes.

---

## Quick Start

### 1. (Optional) Custom Configuration
You can copy `.env.example` to `.env` to customize ports or credentials:
```bash
cp .env.example .env
```

Default credentials if not configured:
| Service | Parameter | Default Value |
|---|---|---|
| Web UI | URL | `http://localhost:8080` |
| TestLink | Login | `admin` |
| TestLink | Password | `admin` |
| MariaDB | Host / Port | `db:3306` |
| MariaDB | User / Password | `testlink` / `testlink_pass` |
| MariaDB | Root Password | `root_masterkey` |

### 2. Start the Stack
```bash
docker compose up -d
```

### 3. Access TestLink
Open your browser and navigate to:
[http://localhost:8080](http://localhost:8080)

Log in using `admin` / `admin`.

---

## Managing the Stack

### View Logs
```bash
# View combined logs
docker compose logs -f

# View web container logs
docker compose logs -f web

# View database logs
docker compose logs -f db
```

### Stop the Containers
```bash
docker compose down
```

### Stop and Wipe Volumes (Data Reset)
> **Warning**: This permanently removes all test projects, test cases, and database records.
```bash
docker compose down -v
```

---

## Architecture & Persistence

- **`web`**: Runs Apache and PHP 7.4 with TestLink 1.9.20. An automated entrypoint script generates `config_db.inc.php` and `custom_config.inc.php` dynamically.
- **`db`**: Runs MariaDB 10.11 with an integrated healthcheck.
- **Volumes**:
  - `mariadb_data`: Stores database tables (`/var/lib/mysql`).
  - `testlink_uploads`: Stores test case attachments and artifacts (`/var/testlink/upload_area`).
  - `testlink_logs`: Stores application runtime logs (`/var/testlink/logs`).
