#!/bin/bash

################################################################################
# DocuNova 배포 스크립트
# 작성일: 2025-11-02
# 설명: 백엔드 + 프론트엔드 자동 배포 및 서비스 설정
################################################################################

set -e  # 에러 발생 시 스크립트 중단

# 색상 정의
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_step() {
    echo -e "${BLUE}[단계]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[성공]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[경고]${NC} $1"
}

print_error() {
    echo -e "${RED}[에러]${NC} $1"
}

echo "========================================="
echo "🚀 DocuNova 배포 시작"
echo "========================================="
echo ""

# 현재 위치 확인
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

print_step "프로젝트 디렉토리: $PROJECT_DIR"
cd "$PROJECT_DIR"
echo ""

# 공인 IP 자동 감지
PUBLIC_IP=$(curl -s ifconfig.me)
print_step "서버 공인 IP: $PUBLIC_IP"
echo ""

# 사용자 입력: 도메인
read -p "도메인을 사용하시나요? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "도메인 입력 (예: docunova.com): " DOMAIN
    USE_DOMAIN=true
else
    DOMAIN=$PUBLIC_IP
    USE_DOMAIN=false
fi
echo ""

# 1. 백엔드 배포
echo "========================================="
echo "📦 백엔드 배포"
echo "========================================="
echo ""

print_step "백엔드 디렉토리로 이동..."
cd "$PROJECT_DIR/backend"

# Python 가상환경 생성
print_step "Python 가상환경 생성 중..."
if [ -d "venv" ]; then
    print_warning "기존 가상환경 발견. 삭제하고 재생성합니다."
    rm -rf venv
fi

python3.11 -m venv venv
source venv/bin/activate

print_success "가상환경 생성 완료"
echo ""

# 의존성 설치
print_step "Python 패키지 설치 중... (약 2-3분 소요)"
pip install --upgrade pip
pip install -r requirements.txt

print_success "의존성 설치 완료"
echo ""

# 환경변수 파일 생성
print_step "백엔드 환경변수 설정 중..."

cat > .env <<EOF
# Ollama 설정
OLLAMA_HOST=http://localhost:11434

# Qdrant 설정
QDRANT_PATH=./qdrant_storage

# 데이터 경로
DATA_PATH=./data
CHAT_HISTORY_PATH=./chat_history

# CORS 설정
CORS_ORIGINS=http://$DOMAIN,https://$DOMAIN,http://$PUBLIC_IP,https://$PUBLIC_IP

# 로그 레벨
LOG_LEVEL=INFO
EOF

print_success "환경변수 설정 완료"
cat .env
echo ""

# 필수 디렉토리 생성
print_step "필수 디렉토리 생성 중..."
mkdir -p data
mkdir -p qdrant_storage
mkdir -p chat_history

print_success "디렉토리 생성 완료"
echo ""

# Systemd 서비스 파일 생성
print_step "백엔드 Systemd 서비스 생성 중..."

cat > /etc/systemd/system/docunova-backend.service <<EOF
[Unit]
Description=DocuNova Backend API
Documentation=https://github.com/your-repo/docunova
After=network.target ollama.service
Wants=ollama.service

[Service]
Type=simple
User=root
WorkingDirectory=$PROJECT_DIR/backend
Environment="PATH=$PROJECT_DIR/backend/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Environment="PYTHONUNBUFFERED=1"
ExecStart=$PROJECT_DIR/backend/venv/bin/python main.py
Restart=always
RestartSec=10
StandardOutput=append:/var/log/docunova/backend.log
StandardError=append:/var/log/docunova/backend-error.log

# 리소스 제한
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

print_success "백엔드 서비스 파일 생성 완료"
echo ""

# 2. 프론트엔드 배포
echo "========================================="
echo "🎨 프론트엔드 배포"
echo "========================================="
echo ""

print_step "프론트엔드 디렉토리로 이동..."
cd "$PROJECT_DIR/frontend"

# 환경변수 파일 생성
print_step "프론트엔드 환경변수 설정 중..."

if [ "$USE_DOMAIN" = true ]; then
    API_URL="https://$DOMAIN"
    WS_URL="wss://$DOMAIN"
else
    API_URL="http://$PUBLIC_IP"
    WS_URL="ws://$PUBLIC_IP"
fi

cat > .env.local <<EOF
# API 엔드포인트
NEXT_PUBLIC_API_URL=$API_URL
NEXT_PUBLIC_WS_URL=$WS_URL

# 환경
NODE_ENV=production
EOF

print_success "환경변수 설정 완료"
cat .env.local
echo ""

# npm 의존성 설치
print_step "npm 패키지 설치 중... (약 2-3분 소요)"
npm install

print_success "의존성 설치 완료"
echo ""

# 프로덕션 빌드
print_step "프로덕션 빌드 생성 중... (약 1-2분 소요)"
npm run build

print_success "빌드 완료"
echo ""

# Systemd 서비스 파일 생성
print_step "프론트엔드 Systemd 서비스 생성 중..."

cat > /etc/systemd/system/docunova-frontend.service <<EOF
[Unit]
Description=DocuNova Frontend (Next.js)
Documentation=https://github.com/your-repo/docunova
After=network.target docunova-backend.service
Wants=docunova-backend.service

[Service]
Type=simple
User=root
WorkingDirectory=$PROJECT_DIR/frontend
Environment="PATH=/usr/bin:/usr/local/bin"
Environment="NODE_ENV=production"
Environment="PORT=3000"
ExecStart=/usr/bin/npm start
Restart=always
RestartSec=10
StandardOutput=append:/var/log/docunova/frontend.log
StandardError=append:/var/log/docunova/frontend-error.log

# 리소스 제한
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

print_success "프론트엔드 서비스 파일 생성 완료"
echo ""

# 3. Nginx 설정
echo "========================================="
echo "🌐 Nginx 리버스 프록시 설정"
echo "========================================="
echo ""

print_step "Nginx 설정 파일 생성 중..."

cat > /etc/nginx/sites-available/docunova <<EOF
# DocuNova Nginx 설정

upstream backend {
    server 127.0.0.1:8000;
    keepalive 64;
}

upstream frontend {
    server 127.0.0.1:3000;
    keepalive 64;
}

server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN;

    # 로그 설정
    access_log /var/log/nginx/docunova-access.log;
    error_log /var/log/nginx/docunova-error.log;

    # 파일 업로드 크기 제한 (100MB)
    client_max_body_size 100M;

    # 타임아웃 설정 (LLM 응답 대기)
    proxy_connect_timeout 300s;
    proxy_send_timeout 300s;
    proxy_read_timeout 300s;

    # 프론트엔드 (/)
    location / {
        proxy_pass http://frontend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }

    # Next.js 정적 파일
    location /_next/static {
        proxy_pass http://frontend;
        proxy_http_version 1.1;
        proxy_cache_bypass \$http_upgrade;

        # 캐싱 설정
        expires 365d;
        add_header Cache-Control "public, immutable";
    }

    # 백엔드 API (/api)
    location /api {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;

        # 버퍼 설정 (대용량 응답)
        proxy_buffering off;
        proxy_buffer_size 4k;
    }

    # Health Check
    location /health {
        proxy_pass http://backend/health;
        access_log off;
    }

    # Docs (Swagger)
    location /docs {
        proxy_pass http://backend/docs;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
    }

    # WebSocket (스트리밍)
    location /ws {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
    }
}
EOF

# 기존 default 설정 비활성화
if [ -L "/etc/nginx/sites-enabled/default" ]; then
    rm /etc/nginx/sites-enabled/default
fi

# 심볼릭 링크 생성
ln -sf /etc/nginx/sites-available/docunova /etc/nginx/sites-enabled/

# Nginx 설정 테스트
print_step "Nginx 설정 테스트 중..."
nginx -t

print_success "Nginx 설정 완료"
echo ""

# 4. 서비스 시작
echo "========================================="
echo "🎬 서비스 시작"
echo "========================================="
echo ""

print_step "Systemd 데몬 리로드..."
systemctl daemon-reload

print_step "Ollama 서비스 시작..."
systemctl restart ollama
systemctl enable ollama
sleep 3

print_step "백엔드 서비스 시작..."
systemctl restart docunova-backend
systemctl enable docunova-backend
sleep 5

print_step "프론트엔드 서비스 시작..."
systemctl restart docunova-frontend
systemctl enable docunova-frontend
sleep 5

print_step "Nginx 서비스 재시작..."
systemctl restart nginx

print_success "모든 서비스 시작 완료"
echo ""

# 5. 서비스 상태 확인
echo "========================================="
echo "📊 서비스 상태 확인"
echo "========================================="
echo ""

# 서비스 상태 확인 함수
check_service() {
    service_name=$1
    if systemctl is-active --quiet $service_name; then
        echo -e "${GREEN}✅ $service_name: 실행 중${NC}"
    else
        echo -e "${RED}❌ $service_name: 중지됨${NC}"
        systemctl status $service_name --no-pager
    fi
}

check_service "ollama"
check_service "docunova-backend"
check_service "docunova-frontend"
check_service "nginx"
echo ""

# 포트 확인
print_step "포트 리스닝 확인..."
netstat -tlnp | grep -E '8000|3000|11434|80'
echo ""

# API 헬스체크
print_step "API 헬스체크..."
sleep 3
if curl -s http://localhost:8000/health > /dev/null; then
    print_success "백엔드 API 정상 작동"
    curl -s http://localhost:8000/health | python3 -m json.tool || echo ""
else
    print_error "백엔드 API 응답 없음. 로그를 확인하세요."
    journalctl -u docunova-backend -n 20 --no-pager
fi
echo ""

# 6. SSL 인증서 설치 (도메인이 있는 경우)
if [ "$USE_DOMAIN" = true ]; then
    echo "========================================="
    echo "🔒 SSL 인증서 설치"
    echo "========================================="
    echo ""

    read -p "SSL 인증서를 설치하시겠습니까? (Let's Encrypt 무료) (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_step "SSL 인증서 설치 중..."

        # 이메일 입력
        read -p "이메일 주소 입력: " EMAIL

        # Certbot 실행
        certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email $EMAIL --redirect

        print_success "SSL 인증서 설치 완료"
        print_step "HTTPS로 자동 리다이렉트 설정됨"
        echo ""

        # 자동 갱신 확인
        print_step "SSL 자동 갱신 테스트..."
        certbot renew --dry-run
        print_success "SSL 자동 갱신 설정 완료"
        echo ""
    fi
fi

# 7. 최종 요약
echo ""
echo "========================================="
echo "🎉 배포 완료!"
echo "========================================="
echo ""
echo "📋 배포 정보:"
echo "  - 프로젝트 경로: $PROJECT_DIR"
echo "  - 공인 IP: $PUBLIC_IP"
if [ "$USE_DOMAIN" = true ]; then
    echo "  - 도메인: $DOMAIN"
fi
echo ""
echo "🌐 접속 URL:"
if [ "$USE_DOMAIN" = true ]; then
    if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
        echo "  - 프론트엔드: https://$DOMAIN"
        echo "  - 백엔드 API: https://$DOMAIN/api/v1"
        echo "  - API 문서: https://$DOMAIN/docs"
    else
        echo "  - 프론트엔드: http://$DOMAIN"
        echo "  - 백엔드 API: http://$DOMAIN/api/v1"
        echo "  - API 문서: http://$DOMAIN/docs"
    fi
else
    echo "  - 프론트엔드: http://$PUBLIC_IP"
    echo "  - 백엔드 API: http://$PUBLIC_IP/api/v1"
    echo "  - API 문서: http://$PUBLIC_IP/docs"
fi
echo ""
echo "📊 서비스 관리 명령어:"
echo "  - 서비스 상태: systemctl status docunova-{backend,frontend}"
echo "  - 서비스 재시작: systemctl restart docunova-{backend,frontend}"
echo "  - 로그 확인: journalctl -u docunova-backend -f"
echo "  - 로그 파일: /var/log/docunova/"
echo ""
echo "🔧 유용한 명령어:"
echo "  - Ollama 모델 리스트: ollama list"
echo "  - Nginx 설정 테스트: nginx -t"
echo "  - Nginx 재시작: systemctl restart nginx"
echo ""
echo "========================================="
echo "✅ DocuNova가 성공적으로 배포되었습니다!"
echo "========================================="
