# config.py

# Toggle this variable:
# True: All endpoints using the conditional dependency will require a valid JWT.
# False: Endpoints will allow unauthenticated access and receive a placeholder user.
import os


AUTH_REQUIRED = False

# JWT settings (kept here for easy access)
SECRET_KEY = "your-super-secret-key" 
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

AUTH_SERVICE_BASE_URL = os.environ.get("AUTH_SERVICE_BASE_URL", "http://localhost:8000/accounts")
ACCOUNT_SERVICE_BASE_URL = os.environ.get("ACCOUNT_SERVICE_BASE_URL", "http://localhost:8001/accounts")
EMPLOYEE_SERVICE_BASE_URL = os.environ.get("EMPLOYEE_SERVICE_BASE_URL", "http://localhost:8002/employees")
ORGANIZATION_SERVICE_BASE_URL = os.environ.get("ORGANIZATION_SERVICE_BASE_URL", "http://localhost:8003/organizations")
PROJECT_SERVICE_BASE_URL = os.environ.get("PROJECT_SERVICE_BASE_URL", "http://localhost:8004/projects")
TASK_SERVICE_BASE_URL = os.environ.get("TASK_SERVICE_BASE_URL", "http://localhost:8005/tasks")
SCHEDULER_SERVICE_BASE_URL = os.environ.get("SCHEDULER_SERVICE_BASE_URL", "http://localhost:8006/schedules")
STORAGE_SERVICE_BASE_URL = os.environ.get("STORAGE_SERVICE_BASE_URL", "http://localhost:8007/storages")