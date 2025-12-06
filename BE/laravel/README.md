# Your Project Name

This project is built with **Laravel** and managed using **Laravel Sail**, which provides a consistent Docker-based development environment.

---

## 🚀 Development Environment Setup

To run this project locally, make sure you have the following installed:

### 1. Prerequisites (Required for Docker Sail)

- **Docker Desktop**  
  Required to run all containers (PHP, MySQL, Redis, Node, etc.).

- **wsl**  
  Required to run Docker Desktop on Windows.

> **Note:** You **do NOT** need to install PHP or Composer on your computer. Sail provides them inside Docker.

---

## 2. Project Installation

Run the following commands in your **Terminal / CMD / PowerShell**.

### 2.1. Clone Project & Install Dependencies

```bash
# 1. Extract the project

# 2. Go into the project directory
wsl -d Ubuntu
cd <path_to_project>/collaborator_online_system

# 3. Start Sail (builds Docker images first time)
./vendor/bin/sail up -d

# 4. Install PHP dependencies (Composer is inside Docker)
./vendor/bin/sail composer install

# 5. Install JavaScript dependencies (npm also runs inside Docker)
./vendor/bin/sail npm install
# Or using Yarn:
# ./vendor/bin/sail yarn install

# 6. Run migrations to create tables
./vendor/bin/sail artisan migrate

# 7. (Optional) Run database seeders
./vendor/bin/sail artisan db:seed

# 8. Compile assets
./vendor/bin/sail npm run dev

# 9. Start Reverb
./vendor/bin/sail artisan reverb:start 

# 10. Start Queue Worker
./vendor/bin/sail artisan queue:work
```

