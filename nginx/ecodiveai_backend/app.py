from flask import Flask, request, jsonify
import sqlite3
import hashlib
import uuid
import logging
import ssl
from flask_cors import CORS

# 로깅 설정 강화
logging.basicConfig(
    level=logging.DEBUG,  # 디버그 레벨로 설정
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler()  # 터미널에 출력
    ]
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app, resources={r"/api/*": {"origins": "*"}})  # 모든 출처 허용 (개발용)

# SQLite 데이터베이스 초기화
def init_db():
    conn = sqlite3.connect('users.db')
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS users
                 (id TEXT PRIMARY KEY, email TEXT UNIQUE, password TEXT, name TEXT)''')
    conn.commit()
    conn.close()
    logger.info("Database initialized successfully")

# 데이터베이스 연결
def get_db():
    conn = sqlite3.connect('users.db')
    return conn

# 비밀번호 해싱 (Google 로그인에는 비밀번호 없음, 필요 시 더미 값 사용)
def hash_password(password):
    return hashlib.sha256(password.encode()).hexdigest() if password else None

@app.route('/api/version', methods=['GET'])
def get_version():
    logger.debug(f"Received version request: aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
    return jsonify({
      "success": True,
    }), 200

@app.route('/api/auth/signup', methods=['POST'])
def signup():
    data = request.get_json()
    logger.debug(f"Received signup request: {data}")
    email = data.get('email')
    password = data.get('password')
    name = data.get('name', email.split('@')[0])  # 이름이 없으면 이메일에서 추출

    if not email or not password:
        logger.error("Email and password are required")
        return jsonify({"error": "Email and password are required"}), 400

    conn = get_db()
    c = conn.cursor()
    hashed_password = hash_password(password)
    user_id = str(uuid.uuid4())  # 고유 ID 생성

    # 이메일 중복 확인
    c.execute("SELECT email FROM users WHERE email = ?", (email,))
    if c.fetchone():
        logger.warning(f"Email already exists: {email}")
        conn.close()
        return jsonify({"error": "Email already exists. Please use a different email or sign in."}), 409

    try:
        c.execute("INSERT INTO users (id, email, password, name) VALUES (?, ?, ?, ?)",
                  (user_id, email, hashed_password, name))
        conn.commit()
        logger.info(f"User registered successfully: {email}")
        conn.close()
        return jsonify({
            "success": True,
            "message": "User registered successfully",
            "user": {"name": name, "email": email}
        }), 201
    except sqlite3.Error as e:
        logger.error(f"Database error: {str(e)}")
        conn.close()
        return jsonify({"error": f"Database error: {str(e)}"}), 500

@app.route('/api/auth/signin', methods=['POST'])
def signin():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        return jsonify({"error": "Email and password are required"}), 400

    conn = get_db()
    c = conn.cursor()
    hashed_password = hash_password(password)

    c.execute("SELECT id, name, email FROM users WHERE email = ? AND password = ?", (email, hashed_password))
    user = c.fetchone()
    conn.close()

    if user:
        logger.info(f"User signed in successfully: {email}")
        return jsonify({
            "success": True,
            "user": {
                "id": user[0],
                "name": user[1],
                "email": user[2]
            }
        }), 200
    logger.warning(f"Invalid login attempt for email: {email}")
    return jsonify({"error": "Invalid email or password. If you don't have an account, please sign up."}), 401

@app.route('/api/auth/user', methods=['GET'])
def get_user():
    # 여기서는 간단히 헤더에서 이메일을 확인 (실제로는 JWT 토큰 사용 권장)
    email = request.headers.get('X-User-Email')
    if not email:
        logger.error("Authentication required")
        return jsonify({"error": "Authentication required"}), 401

    conn = get_db()
    c = conn.cursor()
    c.execute("SELECT id, name, email FROM users WHERE email = ?", (email,))
    user = c.fetchone()
    conn.close()

    if user:
        logger.info(f"User retrieved successfully: {email}")
        return jsonify({
            "success": True,
            "user": {
                "id": user[0],
                "name": user[1],
                "email": user[2]
            }
        }), 200
    logger.warning(f"User not found: {email}")
    return jsonify({"error": "User not found"}), 404

@app.route('/api/auth/google-signup', methods=['POST'])
def google_signup():
    data = request.get_json()
    logger.debug(f"Received Google signup request: {data}")
    email = data.get('email')
    name = data.get('name', email.split('@')[0])  # 이름이 없으면 이메일에서 추출

    if not email:
        logger.error("Email is required for Google signup")
        return jsonify({"error": "Email is required"}), 400

    conn = get_db()
    c = conn.cursor()
    user_id = str(uuid.uuid4())  # 고유 ID 생성

    # 이메일 중복 확인
    c.execute("SELECT email FROM users WHERE email = ?", (email,))
    if c.fetchone():
        logger.warning(f"Google user email already exists: {email}")
        conn.close()
        return jsonify({"error": "Email already exists. Please sign in."}), 409

    try:
        # Google 로그인에는 비밀번호가 없으므로 NULL 또는 더미 값 사용
        c.execute("INSERT INTO users (id, email, password, name) VALUES (?, ?, NULL, ?)",
                  (user_id, email, name))
        conn.commit()
        logger.info(f"Google user registered successfully: {email}, Name: {name}")
        conn.close()
        return jsonify({
            "success": True,
            "message": "Google user registered successfully",
            "user": {"name": name, "email": email}
        }), 201
    except sqlite3.Error as e:
        logger.error(f"Database error for Google signup: {str(e)}")
        conn.close()
        return jsonify({"error": f"Database error: {str(e)}"}), 500

if __name__ == '__main__':
    init_db()  # 데이터베이스 초기화
    context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
    context.load_cert_chain('/app/certs/cert.pem', '/app/certs/key.pem')
    #context.load_cert_chain('./certs/cert.pem', './certs/key.pem')
    logger.info("Flask server starting on port 5000")
    app.run(debug=True, host='0.0.0.0', port=5000, ssl_context=context)  # 모든 네트워크에서 접근 가능
