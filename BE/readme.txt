1. trong folder BE/Python, tải dependencies (dùng python >=3.8 & <3.11): pip install -r requirements.txt
2. trong folder BE/Python, chạy: uvicorn app.main:app --host 0.0.0.0 --port 8000
3. trong file database.py có: SQLALCHEMY_DATABASE_URL = "mysql+mysqlconnector://root:@localhost:3306/elearning_db"
đổi elearning_db thành tên database bản thân đang xài
4. You need to install docker to run these service,after install docker then run this command in BE folder: docker compose up -d --build
