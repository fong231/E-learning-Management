# 1. Base Image: Use a small, secure base
FROM python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# 2. Dependencies
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 3. Application Code
COPY . .

# 4. Expose Port (Optional, but useful documentation)
EXPOSE 8000

# 5. Command is typically overridden by docker-compose
# CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]