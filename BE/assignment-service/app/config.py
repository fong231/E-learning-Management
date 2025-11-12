# config.py

# Toggle this variable:
# True: All endpoints using the conditional dependency will require a valid JWT.
# False: Endpoints will allow unauthenticated access and receive a placeholder user.
AUTH_REQUIRED = False

# JWT settings (kept here for easy access)
SECRET_KEY = "your-super-secret-key" 
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 120

GROUP_BASE_URL = "http://localhost:8001/groups"
CONTENT_BASE_URL = "http://localhost:8001/contents"
STUDENT_GROUP_BASE_URL = "http://localhost:8001/groups"
STUDENT_BASE_URL = "http://localhost:8002/students"

TOKEN_URL = "http://localhost:8001/auth/login"