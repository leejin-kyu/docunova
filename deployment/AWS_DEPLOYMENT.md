# 🚀 DocuNova AWS 배포 가이드

**작성일**: 2025-11-02
**플랫폼**: Amazon Web Services (AWS)
**예상 비용**: 월 약 $60-80 (₩80,000-100,000)

---

## 📋 목차

1. [AWS 소개](#aws-소개)
2. [사전 준비사항](#사전-준비사항)
3. [VPC 및 네트워크 설정](#vpc-및-네트워크-설정)
4. [EC2 인스턴스 생성](#ec2-인스턴스-생성)
5. [배포 방법](#배포-방법)
6. [도메인 및 SSL 설정](#도메인-및-ssl-설정)
7. [모니터링 및 관리](#모니터링-및-관리)
8. [비용 최적화](#비용-최적화)
9. [문제 해결](#문제-해결)

---

## 🌐 AWS 소개

### 왜 AWS인가?

✅ **장점**:
- 🌍 글로벌 리전 (전 세계 30개 이상)
- 🔧 방대한 서비스 생태계 (S3, Lambda, RDS 등)
- 📈 무한한 확장성
- 🎓 풍부한 학습 자료 및 커뮤니티
- 🆓 12개월 프리티어 (단, DocuNova는 해당 안 됨)

⚠️ **주의사항**:
- DocuNova는 최소 8GB RAM 필요 → AWS 프리티어 (1GB) 사용 불가
- 설정이 복잡함 (VPC, IAM, Security Group 등)
- 한글 지원 제한적
- 비용이 상대적으로 높음

---

## 🛠 사전 준비사항

### 1️⃣ AWS 계정 생성

1. [AWS 콘솔](https://aws.amazon.com/ko/) 접속
2. "AWS 계정 생성" 클릭
3. 이메일 및 결제 정보 입력
   - 신용카드 필수 (₩1,000 인증 결제)
4. 본인 확인 (전화번호 인증)
5. 지원 플랜 선택 (Basic - 무료)

### 2️⃣ IAM 사용자 생성 (권장)

**보안을 위해 루트 계정 대신 IAM 사용자 사용**

1. AWS 콘솔 → IAM → Users → Add users
2. 사용자 이름: `docunova-admin`
3. Access type: `AWS Management Console access` 체크
4. 권한: `AdministratorAccess` (관리자)
5. 사용자 생성 후 로그인 URL 저장

### 3️⃣ AWS CLI 설치 (선택사항)

```bash
# Windows (PowerShell)
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi

# Mac
brew install awscli

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# 설치 확인
aws --version
```

### 4️⃣ 필요한 정보 준비

- [ ] AWS 계정
- [ ] IAM 사용자 (권장)
- [ ] 신용카드
- [ ] SSH 키페어
- [ ] 도메인 (선택사항)

---

## 🌐 VPC 및 네트워크 설정

### Step 1: VPC 생성

1. **AWS 콘솔** → **VPC** → **VPC 생성**

2. **설정**:
   - 이름: `docunova-vpc`
   - IPv4 CIDR: `10.0.0.0/16`
   - IPv6 CIDR: 없음
   - 테넌시: 기본값

3. **생성** 클릭

### Step 2: 서브넷 생성

**Public 서브넷** (인터넷 접근 가능)

1. VPC → 서브넷 → 서브넷 생성
2. 설정:
   - VPC: `docunova-vpc`
   - 이름: `docunova-public-subnet`
   - 가용 영역: `ap-northeast-2a` (서울 리전)
   - IPv4 CIDR: `10.0.1.0/24`

3. 생성 후 설정:
   - 서브넷 선택 → 작업 → 자동 할당 IP 설정 수정
   - "퍼블릭 IPv4 주소 자동 할당 활성화" 체크

### Step 3: 인터넷 게이트웨이 생성

1. VPC → 인터넷 게이트웨이 → 인터넷 게이트웨이 생성
2. 이름: `docunova-igw`
3. 생성 후:
   - 작업 → VPC에 연결
   - VPC: `docunova-vpc` 선택

### Step 4: 라우팅 테이블 설정

1. VPC → 라우팅 테이블
2. `docunova-vpc`의 메인 라우팅 테이블 선택
3. 이름 태그: `docunova-public-rt`
4. 라우팅 탭 → 라우팅 편집
5. 라우팅 추가:
   - 대상: `0.0.0.0/0`
   - 대상: `docunova-igw` (인터넷 게이트웨이)
6. 저장

7. 서브넷 연결 탭 → 서브넷 연결 편집
   - `docunova-public-subnet` 선택
   - 저장

---

## 🖥 EC2 인스턴스 생성

### Step 1: EC2 인스턴스 시작

1. **EC2 콘솔** → **인스턴스** → **인스턴스 시작**

### Step 2: AMI 선택

- **이름**: `docunova-server`
- **AMI**: Ubuntu Server 22.04 LTS (64비트 x86)
- **아키텍처**: 64비트 (x86)

### Step 3: 인스턴스 유형 선택

**권장 사양** (Ollama LLM 실행 기준):

| 인스턴스 유형 | vCPU | 메모리 | 월 비용 (온디맨드) |
|-------------|------|--------|------------------|
| **t3.large** | 2 | 8GB | ~$60 (₩80,000) |
| **t3.xlarge** | 4 | 16GB | ~$120 (₩160,000) |
| **m5.large** | 2 | 8GB | ~$70 (₩90,000) |

**추천**: `t3.large` (2 vCPU, 8GB RAM)

### Step 4: 키 페어 생성

1. **키 페어 생성**:
   - 이름: `docunova-key`
   - 키 페어 유형: RSA
   - 프라이빗 키 파일 형식: `.pem`

2. **다운로드**:
   - `docunova-key.pem` 파일 다운로드
   - **중요**: 재발급 불가능하므로 안전하게 보관!

### Step 5: 네트워크 설정

- **VPC**: `docunova-vpc`
- **서브넷**: `docunova-public-subnet`
- **퍼블릭 IP 자동 할당**: 활성화
- **보안 그룹** 생성:
  - 이름: `docunova-sg`
  - 설명: DocuNova security group

**인바운드 규칙**:

| 유형 | 프로토콜 | 포트 범위 | 소스 | 설명 |
|------|---------|----------|------|------|
| SSH | TCP | 22 | 내 IP | SSH 접속 |
| HTTP | TCP | 80 | 0.0.0.0/0 | HTTP |
| HTTPS | TCP | 443 | 0.0.0.0/0 | HTTPS |
| 사용자 지정 TCP | TCP | 8000 | 0.0.0.0/0 | 백엔드 API |
| 사용자 지정 TCP | TCP | 3000 | 0.0.0.0/0 | 프론트엔드 |

### Step 6: 스토리지 구성

- **루트 볼륨**:
  - 크기: 50GB
  - 볼륨 유형: gp3 (범용 SSD)
  - 종료 시 삭제: 예

### Step 7: 고급 세부 정보 (선택사항)

- **사용자 데이터** (자동 설정 스크립트):

```bash
#!/bin/bash
apt update -y
apt upgrade -y
```

### Step 8: 인스턴스 시작

- 설정 검토
- **인스턴스 시작** 클릭
- 인스턴스 시작 대기 (약 2-3분)

### Step 9: Elastic IP 할당 (고정 IP)

1. EC2 → 네트워크 및 보안 → Elastic IP
2. Elastic IP 주소 할당
3. 할당된 IP 선택 → 작업 → Elastic IP 주소 연결
4. 인스턴스: `docunova-server` 선택
5. 연결

**주의**: Elastic IP는 인스턴스에 연결되어 있으면 무료, 미사용 시 과금!

---

## 🚀 배포 방법

### Step 1: EC2 인스턴스 접속

#### Windows (PowerShell):

```powershell
# PEM 키 권한 설정 (파일 우클릭 → 속성 → 보안)
# 또는 WSL 사용:
wsl chmod 400 docunova-key.pem

# SSH 접속
ssh -i "docunova-key.pem" ubuntu@[Elastic-IP]
```

#### Mac/Linux:

```bash
# 키 권한 설정
chmod 400 docunova-key.pem

# SSH 접속
ssh -i docunova-key.pem ubuntu@[Elastic-IP]
```

### Step 2: 서버 초기 설정

**서버에서 실행**:

```bash
# 시스템 업데이트
sudo apt update -y && sudo apt upgrade -y

# 필수 패키지 설치
sudo apt install -y git curl wget build-essential

# DocuNova 디렉토리 생성
sudo mkdir -p /var/www/docunova
sudo chown ubuntu:ubuntu /var/www/docunova
```

### Step 3: 초기 설정 스크립트 실행

**네이버 클라우드와 동일한 스크립트 사용 가능!**

```bash
# 스크립트 다운로드 (로컬에서 업로드 또는 직접 생성)
cd /tmp

# 스크립트 생성 (setup_ncp_server.sh와 동일)
# 내용은 네이버 클라우드 가이드 참조

# 실행 권한
chmod +x setup_aws_server.sh

# 실행
./setup_aws_server.sh
```

**또는 수동 설치**:

```bash
# Python 3.11
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update -y
sudo apt install -y python3.11 python3.11-venv python3.11-dev python3-pip

# Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt install -y nodejs

# Nginx
sudo apt install -y nginx

# Certbot
sudo apt install -y certbot python3-certbot-nginx

# Ollama
curl -fsSL https://ollama.com/install.sh | sh
sudo systemctl start ollama
sudo systemctl enable ollama

# LLM 모델 다운로드
ollama pull llama3.1:8b
ollama pull nomic-embed-text

# UFW 방화벽
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8000/tcp
sudo ufw allow 3000/tcp
sudo ufw --force enable
```

### Step 4: DocuNova 코드 업로드

**로컬 컴퓨터에서**:

```powershell
# Windows PowerShell
scp -i "docunova-key.pem" -r "C:\Users\leeji\Desktop\006 Web_page\DocuNova_FINAL" ubuntu@[Elastic-IP]:/var/www/docunova
```

```bash
# Mac/Linux
scp -i docunova-key.pem -r ~/Desktop/DocuNova_FINAL ubuntu@[Elastic-IP]:/var/www/docunova
```

### Step 5: 배포 스크립트 실행

**서버에서**:

```bash
cd /var/www/docunova

# 배포 스크립트 실행 (네이버 클라우드와 동일)
chmod +x deployment/deploy_docunova.sh
./deployment/deploy_docunova.sh
```

스크립트가 자동으로:
- ✅ 백엔드 설정 및 서비스 생성
- ✅ 프론트엔드 빌드 및 서비스 생성
- ✅ Nginx 리버스 프록시 설정
- ✅ 모든 서비스 시작

### Step 6: 접속 확인

브라우저에서:
```
http://[Elastic-IP]
```

---

## 🔒 도메인 및 SSL 설정

### Step 1: Route 53에서 도메인 등록 (선택)

1. Route 53 → 도메인 등록
2. 도메인 검색 및 구매 (연간 $12-50)

또는 외부 도메인 사용 (가비아, 후이즈 등)

### Step 2: Route 53 호스팅 영역 생성

1. Route 53 → 호스팅 영역 → 호스팅 영역 생성
2. 도메인 이름: `docunova.com`
3. 유형: 퍼블릭 호스팅 영역

### Step 3: A 레코드 추가

1. 호스팅 영역 선택 → 레코드 생성
2. 설정:
   - 레코드 이름: (비워두기 또는 www)
   - 레코드 유형: A
   - 값: [Elastic-IP]
   - TTL: 300초
3. 레코드 생성

### Step 4: SSL 인증서 설치 (Let's Encrypt)

**서버에서**:

```bash
# Certbot으로 자동 설치
sudo certbot --nginx -d docunova.com -d www.docunova.com

# 이메일 입력
# 약관 동의
# HTTP to HTTPS 리다이렉트: Yes (2)

# 자동 갱신 확인
sudo certbot renew --dry-run
```

또는 **AWS Certificate Manager (ACM)** 사용:

1. ACM → 인증서 요청
2. 퍼블릭 인증서 요청
3. 도메인 이름: `docunova.com`, `*.docunova.com`
4. DNS 검증
5. Route 53에 CNAME 레코드 자동 추가
6. ALB (Application Load Balancer)에 연결

---

## 📊 모니터링 및 관리

### CloudWatch 모니터링

1. **CloudWatch 콘솔** → **지표**
2. EC2 → 인스턴스별 지표
3. 모니터링 항목:
   - CPUUtilization (CPU 사용률)
   - NetworkIn/Out (네트워크)
   - DiskReadBytes/WriteBytes (디스크 I/O)

### CloudWatch 알람 설정

```bash
# 예: CPU 사용률 80% 초과 시 알림
1. CloudWatch → 알람 → 알람 생성
2. 지표: EC2 → CPUUtilization
3. 조건: >= 80%
4. 작업: SNS 주제 생성 (이메일 알림)
```

### 로그 관리

**CloudWatch Logs Agent 설치**:

```bash
# 서버에서
wget https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py
sudo python3 ./awslogs-agent-setup.py --region ap-northeast-2

# 로그 그룹 설정
# - /var/log/docunova/backend.log
# - /var/log/docunova/frontend.log
```

### 백업 (EBS 스냅샷)

```bash
# AWS CLI 사용
aws ec2 create-snapshot --volume-id vol-xxxxx --description "DocuNova backup"

# 또는 콘솔에서:
# EC2 → 볼륨 → 작업 → 스냅샷 생성
```

**자동 백업 (Data Lifecycle Manager)**:

1. EC2 → Lifecycle Manager → 라이프사이클 정책 생성
2. 매일 자동 스냅샷 생성 설정

---

## 💰 비용 최적화

### 1️⃣ 예약 인스턴스 (1년 약정)

- 온디맨드 대비 최대 **72% 할인**
- t3.large: $60/월 → $35/월 (약 40% 할인)

### 2️⃣ Savings Plans

- 1년 또는 3년 약정
- 유연한 인스턴스 변경 가능
- 최대 72% 할인

### 3️⃣ Spot 인스턴스 (비추천)

- 온디맨드 대비 90% 할인
- **단점**: 언제든 종료 가능 (프로덕션 부적합)

### 4️⃣ 비용 모니터링

**AWS Budgets 설정**:

1. Billing → Budgets → 예산 생성
2. 월 예산: $100
3. 알림: 80% 초과 시 이메일

**Cost Explorer**:
- 비용 분석 및 추세 확인
- 서비스별 비용 분해

### 5️⃣ 불필요한 리소스 정리

```bash
# 미사용 Elastic IP 해제
# 미사용 EBS 볼륨 삭제
# 오래된 스냅샷 삭제
# CloudWatch Logs 보존 기간 설정 (7일)
```

---

## 월 예상 비용 (상세)

| 항목 | 스펙 | 월 비용 (USD) | 월 비용 (KRW) |
|------|------|--------------|--------------|
| **EC2 (t3.large)** | 2 vCPU, 8GB | $60 | ₩80,000 |
| **EBS (gp3)** | 50GB | $4 | ₩5,000 |
| **Elastic IP** | 1개 (연결됨) | $0 | ₩0 |
| **데이터 전송** | 100GB 아웃바운드 | $9 | ₩12,000 |
| **스냅샷 (백업)** | 50GB | $2.5 | ₩3,000 |
| **총계** | - | **$75.5** | **₩100,000** |

**예약 인스턴스 사용 시**:
- EC2: $60 → $35 (-40%)
- 총계: **$50.5/월** (₩67,000)

---

## 🐛 문제 해결

### 1. SSH 접속 실패

```bash
# 권한 확인
chmod 400 docunova-key.pem

# Security Group 확인
# - 인바운드 규칙에 SSH (22) 포트 열려있는지 확인
# - 내 IP 주소 확인

# 올바른 사용자명 사용
# Ubuntu AMI: ubuntu@
# Amazon Linux: ec2-user@
ssh -i docunova-key.pem ubuntu@[Elastic-IP]
```

### 2. Ollama 연결 실패

```bash
sudo systemctl status ollama
sudo systemctl restart ollama
ollama list
```

### 3. 메모리 부족

```bash
# 스왑 메모리 추가
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### 4. Nginx 502 Bad Gateway

```bash
sudo systemctl status docunova-backend
sudo systemctl status docunova-frontend
sudo journalctl -u docunova-backend -n 50
```

---

## 🔐 보안 강화

### IAM 역할 연결

```bash
# EC2 인스턴스에 IAM 역할 연결 (S3 접근 등)
1. IAM → 역할 → 역할 생성
2. 신뢰할 수 있는 엔터티: EC2
3. 정책: AmazonS3ReadOnlyAccess (예시)
4. EC2 → 인스턴스 → 작업 → 보안 → IAM 역할 수정
```

### SSH 키 기반 인증만 허용

```bash
# /etc/ssh/sshd_config
sudo nano /etc/ssh/sshd_config

# 변경
PasswordAuthentication no
PermitRootLogin no

# 재시작
sudo systemctl restart sshd
```

### Fail2Ban 설치 (무차별 대입 공격 방어)

```bash
sudo apt install -y fail2ban
sudo systemctl start fail2ban
sudo systemctl enable fail2ban
```

---

## 📚 유용한 AWS CLI 명령어

```bash
# 인스턴스 목록
aws ec2 describe-instances --region ap-northeast-2

# 인스턴스 시작/중지
aws ec2 start-instances --instance-ids i-xxxxx
aws ec2 stop-instances --instance-ids i-xxxxx

# 스냅샷 생성
aws ec2 create-snapshot --volume-id vol-xxxxx --description "backup"

# CloudWatch 지표 확인
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-xxxxx \
  --start-time 2025-01-01T00:00:00Z \
  --end-time 2025-01-02T00:00:00Z \
  --period 3600 \
  --statistics Average
```

---

## ✅ AWS 배포 체크리스트

- [ ] AWS 계정 생성
- [ ] IAM 사용자 생성
- [ ] VPC 생성
- [ ] 서브넷 생성 (Public)
- [ ] 인터넷 게이트웨이 생성 및 연결
- [ ] 라우팅 테이블 설정
- [ ] EC2 인스턴스 생성 (t3.large)
- [ ] Security Group 설정
- [ ] 키 페어 다운로드 및 보관
- [ ] Elastic IP 할당 및 연결
- [ ] SSH 접속 확인
- [ ] 서버 초기 설정 완료
- [ ] DocuNova 코드 업로드
- [ ] 배포 스크립트 실행
- [ ] 서비스 정상 작동 확인
- [ ] 도메인 연결 (선택)
- [ ] SSL 인증서 설치 (선택)
- [ ] CloudWatch 모니터링 설정
- [ ] 백업 설정 (스냅샷)
- [ ] 비용 알람 설정

---

## 🎉 배포 완료!

AWS에서 DocuNova가 성공적으로 배포되었습니다!

**다음 단계**:
- CloudWatch로 모니터링
- 비용 최적화 (예약 인스턴스)
- 백업 자동화
- 보안 강화 (IAM, Fail2Ban)

**참고 문서**:
- `AWS_VS_NCP_COMPARISON.md` - AWS vs 네이버 비교
- `NAVER_CLOUD_DEPLOYMENT.md` - 네이버 클라우드 가이드
- [AWS 공식 문서](https://docs.aws.amazon.com/)

---

**Good luck! 🚀**
