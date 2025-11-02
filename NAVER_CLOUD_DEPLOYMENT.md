# 🚀 DocuNova 네이버 클라우드 플랫폼 배포 가이드

**작성일**: 2025-11-02
**플랫폼**: Naver Cloud Platform (NCP)
**예상 비용**: 월 약 50,000~80,000원

---

## 📋 목차

1. [네이버 클라우드 소개](#네이버-클라우드-소개)
2. [사전 준비사항](#사전-준비사항)
3. [서버 생성 및 설정](#서버-생성-및-설정)
4. [배포 방법](#배포-방법)
5. [도메인 및 SSL 설정](#도메인-및-ssl-설정)
6. [모니터링 및 관리](#모니터링-및-관리)
7. [비용 최적화](#비용-최적화)
8. [문제 해결](#문제-해결)

---

## 🌐 네이버 클라우드 소개

### 왜 네이버 클라우드인가?

✅ **장점**:
- 🇰🇷 한국 리전 - 빠른 속도 (서울, 부산)
- 💰 합리적인 가격 (AWS 대비 10-20% 저렴)
- 📞 한국어 지원 및 국내 기술지원
- 🎁 신규 가입 시 크레딧 제공 (100,000원)
- 🔒 개인정보보호법 준수 (국내 데이터 보관)

### 서비스 구성

이 가이드에서 사용할 NCP 서비스:
- **Server (Compute)**: 가상 서버 (VPC 환경)
- **Public IP**: 고정 IP 주소
- **Load Balancer**: (선택사항) 트래픽 분산
- **Cloud DB for MySQL**: (선택사항) 데이터베이스
- **Object Storage**: (선택사항) 파일 저장소
- **SSL Certificate**: HTTPS 설정

---

## 🛠 사전 준비사항

### 1️⃣ 네이버 클라우드 계정 생성

1. [네이버 클라우드 플랫폼](https://www.ncloud.com) 접속
2. 회원가입 (네이버 계정 필요)
3. 본인인증 및 결제수단 등록
4. 신규 가입 크레딧 확인 (100,000원)

### 2️⃣ 필요한 정보 준비

- [ ] 네이버 클라우드 계정
- [ ] 신용카드 또는 계좌정보 (자동결제용)
- [ ] 도메인 (선택사항, 예: docunova.com)
- [ ] SSH 키페어 (서버 접속용)

### 3️⃣ 로컬 개발환경

```bash
# Git 설치 확인
git --version

# SSH 키 생성 (없는 경우)
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

---

## 🖥 서버 생성 및 설정

### Step 1: VPC 생성

1. NCP 콘솔 → **VPC** → **VPC 관리**
2. **VPC 생성**:
   - VPC 이름: `docunova-vpc`
   - IP 주소 범위: `10.0.0.0/16`
   - 리전: `KR-1 (한국)`

3. **Subnet 생성**:
   - 서브넷 이름: `docunova-subnet`
   - IP 주소 범위: `10.0.1.0/24`
   - Zone: `KR-1` 또는 `KR-2`

### Step 2: 서버 생성

#### A) 서버 스펙 선택

**권장 사양** (Ollama LLM 실행 기준):

| 항목 | 스펙 | 월 비용 (예상) |
|------|------|--------------|
| **CPU** | 4 vCPU | - |
| **메모리** | 8GB RAM | - |
| **스토리지** | 50GB SSD | - |
| **OS** | Ubuntu 22.04 LTS | - |
| **총 비용** | - | 약 60,000원 |

**서버 타입**: `Standard` (범용)

#### B) 서버 생성 단계

1. NCP 콘솔 → **Server** → **Server**
2. **서버 생성** 클릭
3. 설정:
   - **서버 이미지**: Ubuntu Server 22.04 LTS
   - **서버 타입**: Standard
   - **서버 스펙**:
     - vCPU: 4개
     - Memory: 8GB
     - Storage: 50GB
   - **서버 이름**: `docunova-server`
   - **VPC**: 위에서 생성한 `docunova-vpc` 선택
   - **Subnet**: `docunova-subnet` 선택

4. **인증키** 설정:
   - 새로운 인증키 생성 또는 기존 키 사용
   - 인증키 다운로드 (`.pem` 파일)
   - **주의**: 인증키는 재발급 불가능하므로 안전하게 보관!

5. **ACG (Access Control Group)** 설정:
   - 새로운 ACG 생성: `docunova-acg`
   - 규칙 추가:
     ```
     SSH (22)         - 내 IP만 허용
     HTTP (80)        - 0.0.0.0/0 (모두 허용)
     HTTPS (443)      - 0.0.0.0/0 (모두 허용)
     Custom (8000)    - 0.0.0.0/0 (백엔드 API)
     Custom (3000)    - 0.0.0.0/0 (프론트엔드)
     Custom (11434)   - 127.0.0.1 (Ollama, 로컬만)
     ```

6. **Public IP** 할당:
   - 신규 공인 IP 할당
   - 고정 IP 옵션 선택 (권장)

7. **생성 완료**

### Step 3: 서버 접속

#### Windows (PowerShell):

```powershell
# 인증키 권한 설정 (다운로드 폴더에 있다고 가정)
# 파일 우클릭 → 속성 → 보안 → 고급 → 상속 사용 안 함

# SSH 접속
ssh -i "C:\Users\YourName\Downloads\docunova-key.pem" root@[공인IP]
```

#### Linux/Mac:

```bash
# 인증키 권한 설정
chmod 400 ~/Downloads/docunova-key.pem

# SSH 접속
ssh -i ~/Downloads/docunova-key.pem root@[공인IP]
```

---

## 🚀 배포 방법

### 방법 1: 자동 배포 스크립트 (권장)

서버에 접속한 후 다음 스크립트를 실행합니다.

#### 1️⃣ 초기 서버 설정 스크립트

```bash
#!/bin/bash
# setup_ncp_server.sh

echo "🚀 DocuNova NCP 서버 초기 설정 시작..."

# 시스템 업데이트
echo "📦 시스템 업데이트 중..."
apt update && apt upgrade -y

# 필수 패키지 설치
echo "📦 필수 패키지 설치 중..."
apt install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3-pip \
    nginx \
    certbot \
    python3-certbot-nginx

# Node.js 20.x 설치
echo "📦 Node.js 설치 중..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

# Docker 설치 (선택사항)
echo "🐳 Docker 설치 중..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
systemctl start docker
systemctl enable docker

# Ollama 설치
echo "🤖 Ollama 설치 중..."
curl -fsSL https://ollama.com/install.sh | sh

# Ollama 서비스 시작
systemctl start ollama
systemctl enable ollama

# LLM 모델 다운로드 (llama3.1:8b)
echo "📥 LLM 모델 다운로드 중... (약 5-10분 소요)"
ollama pull llama3.1:8b
ollama pull nomic-embed-text

# 방화벽 설정 (ufw)
echo "🔒 방화벽 설정 중..."
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw allow 8000/tcp  # Backend
ufw allow 3000/tcp  # Frontend
ufw --force enable

echo "✅ 서버 초기 설정 완료!"
```

서버에서 실행:
```bash
# 스크립트 다운로드 (나중에 제공)
wget https://raw.githubusercontent.com/YOUR_REPO/setup_ncp_server.sh
chmod +x setup_ncp_server.sh
./setup_ncp_server.sh
```

#### 2️⃣ DocuNova 배포 스크립트

```bash
#!/bin/bash
# deploy_docunova.sh

echo "🚀 DocuNova 배포 시작..."

# 작업 디렉토리 생성
mkdir -p /var/www/docunova
cd /var/www/docunova

# GitHub에서 코드 다운로드 (또는 수동 업로드)
# 방법 1: Git Clone (리포지토리가 있는 경우)
# git clone https://github.com/YOUR_USERNAME/DocuNova.git .

# 방법 2: SCP로 업로드 (로컬에서 실행)
# scp -i docunova-key.pem -r "C:\Users\leeji\Desktop\006 Web_page\DocuNova_FINAL" root@[공인IP]:/var/www/docunova

echo "📦 프로젝트 파일 복사 완료"

# 백엔드 설정
echo "🔧 백엔드 설정 중..."
cd /var/www/docunova/backend

# Python 가상환경 생성 (기존 venv 제거)
rm -rf venv
python3.11 -m venv venv
source venv/bin/activate

# 의존성 설치
pip install --upgrade pip
pip install -r requirements.txt

# 환경변수 설정
cat > .env <<EOF
OLLAMA_HOST=http://localhost:11434
QDRANT_PATH=./qdrant_storage
DATA_PATH=./data
CHAT_HISTORY_PATH=./chat_history
CORS_ORIGINS=http://[공인IP]:3000,https://yourdomain.com
EOF

# 프론트엔드 설정
echo "🔧 프론트엔드 설정 중..."
cd /var/www/docunova/frontend

# 의존성 설치
npm install

# 환경변수 설정
cat > .env.local <<EOF
NEXT_PUBLIC_API_URL=http://[공인IP]:8000
NEXT_PUBLIC_WS_URL=ws://[공인IP]:8000
EOF

# 프로덕션 빌드
npm run build

echo "✅ DocuNova 배포 완료!"
```

#### 3️⃣ Systemd 서비스 설정 (자동 시작)

**백엔드 서비스**:
```bash
cat > /etc/systemd/system/docunova-backend.service <<EOF
[Unit]
Description=DocuNova Backend API
After=network.target ollama.service

[Service]
Type=simple
User=root
WorkingDirectory=/var/www/docunova/backend
Environment="PATH=/var/www/docunova/backend/venv/bin"
ExecStart=/var/www/docunova/backend/venv/bin/python main.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 서비스 시작
systemctl daemon-reload
systemctl start docunova-backend
systemctl enable docunova-backend
systemctl status docunova-backend
```

**프론트엔드 서비스**:
```bash
cat > /etc/systemd/system/docunova-frontend.service <<EOF
[Unit]
Description=DocuNova Frontend
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/var/www/docunova/frontend
Environment="PATH=/usr/bin"
Environment="PORT=3000"
ExecStart=/usr/bin/npm start
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 서비스 시작
systemctl daemon-reload
systemctl start docunova-frontend
systemctl enable docunova-frontend
systemctl status docunova-frontend
```

#### 4️⃣ Nginx 리버스 프록시 설정

```bash
cat > /etc/nginx/sites-available/docunova <<EOF
server {
    listen 80;
    server_name [공인IP] yourdomain.com;  # 도메인이 있다면 변경

    # 프론트엔드
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # 백엔드 API
    location /api {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        # 타임아웃 설정 (LLM 응답 대기)
        proxy_connect_timeout 300s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;
    }

    # Health check
    location /health {
        proxy_pass http://localhost:8000/health;
    }

    # 파일 업로드 크기 제한
    client_max_body_size 100M;
}
EOF

# 심볼릭 링크 생성
ln -s /etc/nginx/sites-available/docunova /etc/nginx/sites-enabled/

# Nginx 설정 테스트
nginx -t

# Nginx 재시작
systemctl restart nginx
```

#### 5️⃣ 배포 확인

```bash
# 서비스 상태 확인
systemctl status docunova-backend
systemctl status docunova-frontend
systemctl status nginx
systemctl status ollama

# 로그 확인
journalctl -u docunova-backend -f
journalctl -u docunova-frontend -f

# 포트 확인
netstat -tlnp | grep -E '8000|3000|11434|80'

# API 테스트
curl http://localhost:8000/health
curl http://localhost:8000/api/v1/models

# 브라우저에서 접속
# http://[공인IP]
```

---

## 🔒 도메인 및 SSL 설정

### Step 1: 도메인 연결

1. **도메인 구매** (가비아, 후이즈, 네임싸인 등)
   - 예: `docunova.com`

2. **DNS 설정**:
   - A 레코드 추가:
     ```
     호스트: @
     타입: A
     값: [NCP 공인IP]
     TTL: 3600
     ```
   - CNAME 레코드 (선택):
     ```
     호스트: www
     타입: CNAME
     값: docunova.com
     TTL: 3600
     ```

3. **전파 대기** (10분~24시간)
   ```bash
   # DNS 전파 확인
   nslookup docunova.com
   ```

### Step 2: SSL 인증서 설치 (Let's Encrypt - 무료)

```bash
# Certbot으로 자동 설치
certbot --nginx -d docunova.com -d www.docunova.com

# 이메일 입력
# 약관 동의
# HTTP to HTTPS 리다이렉트 선택 (2)

# 자동 갱신 설정 확인
certbot renew --dry-run

# Cron 작업 확인 (자동 갱신)
systemctl status certbot.timer
```

SSL 설치 후 Nginx 설정이 자동으로 업데이트됩니다:
```nginx
server {
    listen 443 ssl;
    server_name docunova.com www.docunova.com;

    ssl_certificate /etc/letsencrypt/live/docunova.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/docunova.com/privkey.pem;

    # ... 나머지 설정 동일
}

# HTTP to HTTPS 리다이렉트
server {
    listen 80;
    server_name docunova.com www.docunova.com;
    return 301 https://$server_name$request_uri;
}
```

---

## 📊 모니터링 및 관리

### 1️⃣ 로그 관리

```bash
# 실시간 로그 모니터링
journalctl -u docunova-backend -f
journalctl -u docunova-frontend -f
journalctl -u nginx -f

# 특정 시간대 로그
journalctl -u docunova-backend --since "1 hour ago"

# 로그 파일 직접 확인
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

### 2️⃣ 리소스 모니터링

```bash
# CPU, 메모리 사용량
htop

# 디스크 사용량
df -h

# 프로세스 확인
ps aux | grep python
ps aux | grep node
ps aux | grep ollama

# 네트워크 연결
netstat -tlnp
```

### 3️⃣ 백업 설정

```bash
#!/bin/bash
# backup.sh

BACKUP_DIR="/var/backups/docunova"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# 데이터 백업
tar -czf $BACKUP_DIR/data_$DATE.tar.gz /var/www/docunova/backend/data
tar -czf $BACKUP_DIR/qdrant_$DATE.tar.gz /var/www/docunova/backend/qdrant_storage
tar -czf $BACKUP_DIR/chat_history_$DATE.tar.gz /var/www/docunova/backend/chat_history

# 7일 이상 된 백업 삭제
find $BACKUP_DIR -type f -mtime +7 -delete

echo "✅ 백업 완료: $DATE"
```

Cron 작업 추가 (매일 새벽 2시):
```bash
crontab -e

# 추가
0 2 * * * /root/backup.sh >> /var/log/docunova_backup.log 2>&1
```

### 4️⃣ NCP 모니터링 콘솔

NCP 콘솔에서 제공하는 모니터링:
1. **Server Monitoring**:
   - CPU 사용률
   - 메모리 사용률
   - 디스크 I/O
   - 네트워크 트래픽

2. **Cloud Insight** (무료):
   - 실시간 메트릭
   - 알림 설정
   - 대시보드

---

## 💰 비용 최적화

### 예상 월 비용 (2025년 기준)

| 서비스 | 스펙 | 월 비용 |
|--------|------|--------|
| Server | 4 vCPU, 8GB RAM, 50GB SSD | 약 60,000원 |
| Public IP | 고정 IP 1개 | 약 3,000원 |
| 아웃바운드 트래픽 | 월 100GB (예상) | 약 5,000원 |
| **총 비용** | - | **약 68,000원** |

### 비용 절감 팁

1. **약정 할인** (1년 약정 시 최대 30% 할인)
2. **스냅샷 대신 백업 스크립트** 사용
3. **불필요한 시간대 서버 중지** (개발/테스트 환경만)
4. **CDN 사용** (정적 파일 - Object Storage + CDN)
5. **모니터링 설정**으로 이상 트래픽 감지

### 프리티어 활용

- 신규 가입 시 100,000원 크레딧
- 약 1.5개월 무료 운영 가능

---

## 🔧 문제 해결

### 1️⃣ 서비스가 시작되지 않을 때

```bash
# 서비스 상태 확인
systemctl status docunova-backend
systemctl status docunova-frontend

# 로그 확인
journalctl -u docunova-backend -n 50
journalctl -u docunova-frontend -n 50

# 수동 실행 테스트
cd /var/www/docunova/backend
source venv/bin/activate
python main.py

cd /var/www/docunova/frontend
npm start
```

### 2️⃣ Ollama 모델 로드 실패

```bash
# Ollama 상태 확인
systemctl status ollama

# 모델 리스트 확인
ollama list

# 모델 재다운로드
ollama pull llama3.1:8b

# Ollama 재시작
systemctl restart ollama
```

### 3️⃣ Nginx 502 Bad Gateway

```bash
# 백엔드/프론트엔드 실행 확인
systemctl status docunova-backend
systemctl status docunova-frontend

# 포트 리스닝 확인
netstat -tlnp | grep -E '8000|3000'

# Nginx 설정 테스트
nginx -t

# Nginx 재시작
systemctl restart nginx
```

### 4️⃣ SSL 인증서 갱신 실패

```bash
# 수동 갱신
certbot renew --force-renewal

# Nginx 재시작
systemctl restart nginx

# 로그 확인
tail -f /var/log/letsencrypt/letsencrypt.log
```

### 5️⃣ 디스크 용량 부족

```bash
# 디스크 사용량 확인
df -h
du -sh /var/www/docunova/*

# 로그 파일 정리
journalctl --vacuum-time=7d

# 오래된 백업 삭제
find /var/backups/docunova -type f -mtime +7 -delete

# npm 캐시 정리
npm cache clean --force

# Docker 정리 (사용 시)
docker system prune -a
```

---

## 📝 체크리스트

배포 전:
- [ ] NCP 계정 생성 및 크레딧 확인
- [ ] VPC 및 서브넷 생성
- [ ] 서버 스펙 확인 (최소 8GB RAM)
- [ ] SSH 키 다운로드 및 백업
- [ ] ACG 규칙 설정

배포 중:
- [ ] 서버 초기 설정 스크립트 실행
- [ ] Ollama 모델 다운로드 (llama3.1:8b)
- [ ] DocuNova 코드 업로드
- [ ] 환경변수 설정 (.env, .env.local)
- [ ] Systemd 서비스 등록
- [ ] Nginx 설정

배포 후:
- [ ] 서비스 정상 작동 확인
- [ ] API 엔드포인트 테스트
- [ ] 프론트엔드 접속 확인
- [ ] 도메인 연결 (선택)
- [ ] SSL 인증서 설치 (선택)
- [ ] 백업 스크립트 설정
- [ ] 모니터링 설정

---

## 🚀 빠른 시작 명령어 모음

```bash
# 1. 서버 접속
ssh -i docunova-key.pem root@[공인IP]

# 2. 초기 설정 (한 번만)
wget https://raw.githubusercontent.com/YOUR_REPO/setup_ncp_server.sh
chmod +x setup_ncp_server.sh
./setup_ncp_server.sh

# 3. 코드 업로드 (로컬에서)
scp -i docunova-key.pem -r "C:\Users\leeji\Desktop\006 Web_page\DocuNova_FINAL" root@[공인IP]:/var/www/docunova

# 4. 배포
cd /var/www/docunova
./deploy_docunova.sh

# 5. 서비스 시작
systemctl start docunova-backend
systemctl start docunova-frontend
systemctl start nginx

# 6. 접속
# http://[공인IP]
```

---

## 📚 참고 자료

- [네이버 클라우드 플랫폼 공식 문서](https://guide.ncloud-docs.com/)
- [Ollama 공식 문서](https://ollama.com/docs)
- [Next.js 배포 가이드](https://nextjs.org/docs/deployment)
- [FastAPI 배포 가이드](https://fastapi.tiangolo.com/deployment/)
- [Nginx 설정 가이드](https://nginx.org/en/docs/)

---

## 💬 문의 및 지원

- NCP 기술지원: 1544-7876 (평일 09:00-18:00)
- NCP 이메일: support@ncloud.com
- NCP 커뮤니티: https://www.ncloud.com/community

---

**배포 성공을 기원합니다! 🎉**
