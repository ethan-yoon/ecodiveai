# 1. Base image: Nginx를 사용하여 웹 앱을 제공
FROM nginx:latest

COPY ./nginx.conf /etc/nginx/conf.d/default.conf
##COPY ./build /usr/share/nginx/html
COPY ./certs/cert.pem /etc/nginx/certs/cert.pem
COPY ./certs/key.pem /etc/nginx/certs/key.pem

# 2. Flutter 웹 앱 빌드 결과물을 Nginx의 기본 웹 루트로 복사
COPY build/web /usr/share/nginx/html

# 3. Nginx 포트(80) 열기
EXPOSE 80 443

# 4. Nginx 서비스 실행
CMD ["nginx", "-g", "daemon off;"]

