#!/bin/bash

################################################################################
# DocuNova NCP 서버 초기 설정 스크립트
# 작성일: 2025-11-02
# 설명: 네이버 클라우드 플랫폼 Ubuntu 서버 초기 설정
################################################################################

set -e  # 에러 발생 시 스크립트 중단

echo "========================================="
echo "🚀 DocuNova NCP 서버 초기 설정 시작"
echo "========================================="
echo ""

# 색상 정의
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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

# 1. 시스템 정보 확인
print_step "시스템 정보 확인 중..."
echo "OS: $(lsb_release -d | cut -f2-)"
echo "커널: $(uname -r)"
echo "메모리: $(free -h | grep Mem | awk '{print $2}')"
echo "CPU: $(nproc) cores"
echo ""

# 최소 요구사항 확인 (8GB RAM)
TOTAL_MEM=$(free -g | grep Mem | awk '{print $2}')
if [ "$TOTAL_MEM" -lt 7 ]; then
    print_warning "메모리가 8GB 미만입니다. Ollama LLM 실행에 문제가 있을 수 있습니다."
    read -p "계속하시겠습니까? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 2. 시스템 업데이트
print_step "시스템 패키지 업데이트 중... (약 2-5분 소요)"
export DEBIAN_FRONTEND=noninteractive
apt update -y
apt upgrade -y
print_success "시스템 업데이트 완료"
echo ""

# 3. 기본 패키지 설치
print_step "기본 패키지 설치 중..."
apt install -y \
    git \
    curl \
    wget \
    vim \
    nano \
    htop \
    net-tools \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    unzip \
    zip \
    ufw

print_success "기본 패키지 설치 완료"
echo ""

# 4. Python 3.11 설치
print_step "Python 3.11 설치 중..."
add-apt-repository -y ppa:deadsnakes/ppa
apt update -y
apt install -y \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3-pip

# Python 기본 버전 설정
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
update-alternatives --set python3 /usr/bin/python3.11

# pip 업그레이드
python3 -m pip install --upgrade pip

print_success "Python 3.11 설치 완료"
python3 --version
echo ""

# 5. Node.js 20.x 설치
print_step "Node.js 20.x 설치 중..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

print_success "Node.js 설치 완료"
node --version
npm --version
echo ""

# 6. Docker 설치 (선택사항)
read -p "Docker를 설치하시겠습니까? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_step "Docker 설치 중..."

    # Docker GPG 키 추가
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Docker 리포지토리 추가
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Docker 설치
    apt update -y
    apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    # Docker 서비스 시작
    systemctl start docker
    systemctl enable docker

    print_success "Docker 설치 완료"
    docker --version
    docker compose version
    echo ""
fi

# 7. Nginx 설치
print_step "Nginx 설치 중..."
apt install -y nginx
systemctl start nginx
systemctl enable nginx

print_success "Nginx 설치 완료"
nginx -v
echo ""

# 8. Certbot 설치 (SSL 인증서용)
print_step "Certbot 설치 중..."
apt install -y certbot python3-certbot-nginx

print_success "Certbot 설치 완료"
certbot --version
echo ""

# 9. Ollama 설치
print_step "Ollama 설치 중... (약 1-2분 소요)"
curl -fsSL https://ollama.com/install.sh | sh

# Ollama 서비스 시작
systemctl start ollama
systemctl enable ollama

# Ollama 시작 대기
sleep 5

print_success "Ollama 설치 완료"
echo ""

# 10. LLM 모델 다운로드
print_step "LLM 모델 다운로드 중..."
read -p "llama3.1:8b 모델을 다운로드하시겠습니까? (약 5-10분 소요) (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_step "llama3.1:8b 모델 다운로드 중... (약 5GB, 5-10분 소요)"
    ollama pull llama3.1:8b
    print_success "llama3.1:8b 모델 다운로드 완료"
fi

read -p "nomic-embed-text 임베딩 모델을 다운로드하시겠습니까? (약 1분 소요) (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_step "nomic-embed-text 모델 다운로드 중..."
    ollama pull nomic-embed-text
    print_success "nomic-embed-text 모델 다운로드 완료"
fi

# 모델 리스트 확인
echo ""
print_step "다운로드된 모델 리스트:"
ollama list
echo ""

# 11. 방화벽 설정 (UFW)
print_step "방화벽(UFW) 설정 중..."

# 기존 방화벽 비활성화
ufw --force disable

# 기본 정책 설정
ufw default deny incoming
ufw default allow outgoing

# 필요한 포트 열기
ufw allow 22/tcp comment 'SSH'
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'
ufw allow 8000/tcp comment 'Backend API'
ufw allow 3000/tcp comment 'Frontend'

# 방화벽 활성화
ufw --force enable

print_success "방화벽 설정 완료"
ufw status
echo ""

# 12. 작업 디렉토리 생성
print_step "작업 디렉토리 생성 중..."
mkdir -p /var/www/docunova
mkdir -p /var/backups/docunova
mkdir -p /var/log/docunova

print_success "작업 디렉토리 생성 완료"
echo ""

# 13. 타임존 설정
print_step "타임존을 Asia/Seoul로 설정 중..."
timedatectl set-timezone Asia/Seoul

print_success "타임존 설정 완료"
date
echo ""

# 14. 스왑 메모리 설정 (8GB 미만인 경우)
if [ "$TOTAL_MEM" -lt 8 ]; then
    print_step "스왑 메모리 설정 중... (메모리가 8GB 미만)"

    # 스왑 파일 생성 (4GB)
    fallocate -l 4G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile

    # 영구 설정
    echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

    print_success "스왑 메모리 설정 완료 (4GB)"
    free -h
    echo ""
fi

# 15. 시스템 최적화
print_step "시스템 최적화 설정 중..."

# 파일 디스크립터 제한 증가
cat >> /etc/security/limits.conf <<EOF

# DocuNova 최적화 설정
* soft nofile 65536
* hard nofile 65536
* soft nproc 65536
* hard nproc 65536
EOF

# sysctl 최적화
cat >> /etc/sysctl.conf <<EOF

# DocuNova 네트워크 최적화
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.ip_local_port_range = 1024 65535
EOF

sysctl -p

print_success "시스템 최적화 완료"
echo ""

# 16. 요약 정보 출력
echo ""
echo "========================================="
echo "✅ 서버 초기 설정 완료!"
echo "========================================="
echo ""
echo "📋 설치된 소프트웨어:"
echo "  - Python: $(python3 --version)"
echo "  - Node.js: $(node --version)"
echo "  - npm: $(npm --version)"
echo "  - Nginx: $(nginx -v 2>&1)"
echo "  - Ollama: ✅ 설치됨"
if command -v docker &> /dev/null; then
    echo "  - Docker: $(docker --version)"
fi
echo ""
echo "📁 작업 디렉토리:"
echo "  - DocuNova: /var/www/docunova"
echo "  - 백업: /var/backups/docunova"
echo "  - 로그: /var/log/docunova"
echo ""
echo "🔒 방화벽 상태:"
ufw status numbered
echo ""
echo "🤖 Ollama 모델:"
ollama list
echo ""
echo "📊 시스템 리소스:"
free -h
echo ""
df -h /
echo ""
echo "========================================="
echo "🎯 다음 단계:"
echo "========================================="
echo ""
echo "1. DocuNova 코드를 서버로 업로드:"
echo "   scp -i docunova-key.pem -r DocuNova_FINAL root@[공인IP]:/var/www/docunova"
echo ""
echo "2. 배포 스크립트 실행:"
echo "   cd /var/www/docunova"
echo "   chmod +x deployment/deploy_docunova.sh"
echo "   ./deployment/deploy_docunova.sh"
echo ""
echo "3. 서비스 시작:"
echo "   systemctl start docunova-backend"
echo "   systemctl start docunova-frontend"
echo ""
echo "4. 브라우저에서 접속:"
echo "   http://[공인IP]"
echo ""
echo "========================================="
echo "🎉 설정이 완료되었습니다!"
echo "========================================="
