cần file .env

# dữ liệu mẫu

########################################
SECRET_KEY="A_Very_Long_Random_String"

# --- DATABASE CONFIGURATION ---
DB_HOST=host.docker.internal
DB_PORT=3306
DB_USER=root
DB_PASS= 

# Database Names (must match what's initialized/created)
DB_NAME_TASK=task-service
DB_NAME_AUTH=authenticate-service
DB_NAME_ACCOUNT=account-service
DB_NAME_EMPLOYEE=employee-service
DB_NAME_ORGANIZATION=organization-service
DB_NAME_PROJECT=project-service
DB_NAME_SCHEDULER=scheduler-service
DB_NAME_STORAGE=storage-service
DB_NAME_NOTIFICATION=notification-service
DB_NAME_MAILER=mailer-service
DB_NAME_REALTIME=realtime-service

# --- SERVICE-TO-SERVICE COMMUNICATION URLs (Docker Network) ---
# FIX: 'localhost' replaced with the service name (e.g., 'auth-service')
# The port must be the INTERNAL container port (the second port in the docker-compose mapping).

AUTH_SERVICE_BASE_URL = "http://auth-service:8000/accounts"
ACCOUNT_SERVICE_BASE_URL = "http://account-service:8001/accounts"
EMPLOYEE_SERVICE_BASE_URL = "http://employee-service:8002/employees"
ORGANIZATION_SERVICE_BASE_URL = "http://organization-service:8003/organizations"
PROJECT_SERVICE_BASE_URL = "http://project-service:8004/projects"
TASK_SERVICE_BASE_URL = "http://task-service:8005/tasks"
SCHEDULER_SERVICE_BASE_URL = "http://scheduler-service:8006/schedules"
STORAGE_SERVICE_BASE_URL = "http://storage-service:8007/storages"
MAILER_SERVICE_BASE_URL = "http://storage-service:8008/storages"
NOTIFICATION_SERVICE_BASE_URL = "http://storage-service:8009/storages"
REALTIME_SERVICE_BASE_URL = "http://storage-service:8010/realtimes"

########################################

