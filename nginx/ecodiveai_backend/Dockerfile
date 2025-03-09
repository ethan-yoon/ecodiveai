# 1. Python 기반 이미지 사용
FROM python:3.10

# 2. 작업 디렉토리 설정
WORKDIR /app

# 3. Flask 앱 코드 복사
COPY . .

COPY ./certs/cert.pem /app/certs/cert.pem
COPY ./certs/key.pem /app/certs/key.pem

# 4. 의존성 설치 (설치된 패키지 확인)
RUN pip install --no-cache-dir -r requirements.txt && pip list

# 5. Gunicorn 실행 (Gunicorn 설치 확인을 위해 `which gunicorn` 추가)
#RUN which gunicorn

# 6. Flask 실행
#CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app:app"]
CMD ["python", "app.py"]

