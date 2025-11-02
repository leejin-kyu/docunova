# 🚀 DocuNova 네이버 클라우드 배포 - 빠른 시작 가이드

이 가이드는 DocuNova를 네이버 클라우드 플랫폼에 빠르게 배포하는 방법을 안내합니다.

---

## 📋 체크리스트

배포 전에 다음을 준비하세요:

- [ ] 네이버 클라우드 계정 (https://www.ncloud.com)
- [ ] 신용카드 또는 계좌정보 (결제수단)
- [ ] 서버 스펙: 최소 4 vCPU, 8GB RAM, 50GB SSD
- [ ] SSH 클라이언트 (Windows: PowerShell, Mac/Linux: Terminal)
- [ ] 도메인 (선택사항)

---

## 🏃 5단계로 배포하기

### 1단계: NCP 서버 생성 (10분)

1. **NCP 콘솔 접속**
   - https://console.ncloud.com 로그인

2. **VPC 생성**
   - VPC → VPC 관리 → VPC 생성
   - VPC 이름: `docunova-vpc`
   - IP 주소 범위: `10.0.0.0/16`

3. **Subnet 생성**
   - 서브넷 이름: `docunova-subnet`
   - IP 주소 범위: `10.0.1.0/24`

4. **서버 생성**
   - Server → Server → 서버 생성
   - **이미지**: Ubuntu Server 22.04 LTS
   - **타입**: Standard
   - **스펙**: 4 vCPU, 8GB RAM, 50GB SSD
   - **서버명**: `docunova-server`
   - **VPC/Subnet**: 위에서 생성한 것 선택
   - **인증키**: 새로 생성 → **다운로드** (중요!)

5. **ACG 설정**
   - 새 ACG 생성: `docunova-acg`
   - 규칙 추가:
     ```
     SSH (22)      - 내 IP만
     HTTP (80)     - 0.0.0.0/0
     HTTPS (443)   - 0.0.0.0/0
     8000          - 0.0.0.0/0
     3000          - 0.0.0.0/0
     ```

6. **Public IP 할당**
   - 고정 IP 선택

7. **서버 시작 대기** (약 2-3분)

---

### 2단계: 서버 접속 및 초기 설정 (15분)

#### Windows:

```powershell
# SSH 접속
ssh -i "C:\Users\YourName\Downloads\docunova-key.pem" root@[공인IP]
```

#### Mac/Linux:

```bash
# 키 권한 설정
chmod 400 ~/Downloads/docunova-key.pem

# SSH 접속
ssh -i ~/Downloads/docunova-key.pem root@[공인IP]
```

#### 서버에서 초기 설정 스크립트 다운로드 및 실행:

```bash
# 임시 디렉토리로 이동
cd /tmp

# 스크립트 생성 (또는 아래 명령어로 직접 다운로드)
wget -O setup_ncp_server.sh [스크립트 URL]

# 또는 수동으로 스크립트 복사 (아래 방법 사용)
cat > setup_ncp_server.sh << 'EOFSCRIPT'
[setup_ncp_server.sh 내용 붙여넣기]
EOFSCRIPT

# 실행 권한 부여
chmod +x setup_ncp_server.sh

# 스크립트 실행 (10-15분 소요)
./setup_ncp_server.sh
```

**이 스크립트가 자동으로 설치하는 것:**
- ✅ Python 3.11
- ✅ Node.js 20
- ✅ Nginx
- ✅ Ollama
- ✅ Docker (선택)
- ✅ LLM 모델 (llama3.1:8b - 약 5GB)
- ✅ 방화벽 설정

---

### 3단계: DocuNova 코드 업로드 (5분)

**로컬 컴퓨터에서** 실행:

#### Windows PowerShell:

```powershell
# DocuNova 프로젝트 디렉토리로 이동
cd "C:\Users\leeji\Desktop\006 Web_page"

# SCP로 업로드 (약 2-3분)
scp -i "C:\Users\YourName\Downloads\docunova-key.pem" -r DocuNova_FINAL root@[공인IP]:/var/www/docunova
```

#### Mac/Linux:

```bash
# DocuNova 프로젝트 디렉토리로 이동
cd ~/Desktop/006\ Web_page

# SCP로 업로드
scp -i ~/Downloads/docunova-key.pem -r DocuNova_FINAL root@[공인IP]:/var/www/docunova
```

---

### 4단계: 배포 스크립트 실행 (10분)

**서버에서** 실행:

```bash
# 프로젝트 디렉토리로 이동
cd /var/www/docunova

# 배포 스크립트 실행 권한 부여
chmod +x deployment/deploy_docunova.sh

# 배포 실행 (10분 소요)
./deployment/deploy_docunova.sh
```

**스크립트 실행 중 질문:**
1. "도메인을 사용하시나요?" → `n` (또는 `y`이고 도메인 입력)
2. "SSL 인증서를 설치하시겠습니까?" → 도메인이 있다면 `y`

**이 스크립트가 자동으로 수행하는 것:**
- ✅ Python 가상환경 생성 및 의존성 설치
- ✅ npm 패키지 설치 및 프로덕션 빌드
- ✅ 환경변수 설정
- ✅ Systemd 서비스 생성 (자동 시작)
- ✅ Nginx 리버스 프록시 설정
- ✅ 모든 서비스 시작
- ✅ 헬스체크

---

### 5단계: 접속 확인 (1분)

브라우저에서 접속:

```
http://[공인IP]
```

또는 도메인을 설정했다면:

```
https://yourdomain.com
```

**확인 사항:**
- ✅ 프론트엔드 페이지 로드
- ✅ 파일 업로드 기능
- ✅ AI 질의응답 기능
- ✅ 문서 검색 기능

---

## 🔧 배포 후 관리

### 서비스 관리

```bash
# 서비스 상태 확인
systemctl status docunova-backend
systemctl status docunova-frontend

# 서비스 재시작
systemctl restart docunova-backend
systemctl restart docunova-frontend

# 로그 확인 (실시간)
journalctl -u docunova-backend -f
journalctl -u docunova-frontend -f

# 로그 파일
tail -f /var/log/docunova/backend.log
tail -f /var/log/docunova/frontend.log
```

### 백업

```bash
# 수동 백업
tar -czf /var/backups/docunova/backup_$(date +%Y%m%d).tar.gz \
  /var/www/docunova/backend/data \
  /var/www/docunova/backend/qdrant_storage \
  /var/www/docunova/backend/chat_history

# 자동 백업 설정 (매일 새벽 2시)
crontab -e

# 추가
0 2 * * * tar -czf /var/backups/docunova/backup_$(date +\%Y\%m\%d).tar.gz /var/www/docunova/backend/data /var/www/docunova/backend/qdrant_storage /var/www/docunova/backend/chat_history
```

### 업데이트

```bash
# 코드 업데이트 (로컬 → 서버)
# 로컬에서:
scp -i docunova-key.pem -r DocuNova_FINAL root@[공인IP]:/var/www/docunova

# 서버에서:
cd /var/www/docunova

# 백엔드 재시작
systemctl restart docunova-backend

# 프론트엔드 재빌드 및 재시작
cd frontend
npm run build
systemctl restart docunova-frontend
```

---

## 🐛 문제 해결

### 1. 서비스가 시작되지 않음

```bash
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

### 2. Ollama 연결 실패

```bash
# Ollama 상태 확인
systemctl status ollama

# Ollama 재시작
systemctl restart ollama

# 모델 확인
ollama list

# 모델 재다운로드
ollama pull llama3.1:8b
```

### 3. Nginx 502 Bad Gateway

```bash
# 백엔드/프론트엔드 실행 확인
systemctl status docunova-backend docunova-frontend

# 포트 리스닝 확인
netstat -tlnp | grep -E '8000|3000'

# Nginx 재시작
nginx -t
systemctl restart nginx
```

### 4. 메모리 부족

```bash
# 메모리 사용량 확인
free -h

# 프로세스 메모리 사용량
ps aux --sort=-%mem | head -10

# Ollama 재시작 (메모리 해제)
systemctl restart ollama
```

---

## 💰 예상 비용

| 항목 | 스펙 | 월 비용 |
|------|------|--------|
| 서버 | 4 vCPU, 8GB RAM | 약 60,000원 |
| 공인 IP | 고정 IP | 약 3,000원 |
| 트래픽 | 100GB/월 | 약 5,000원 |
| **총** | - | **약 68,000원** |

**신규 가입 혜택**: 100,000원 크레딧 → **약 1.5개월 무료**

---

## 📞 지원

### NCP 고객센터
- 전화: 1544-7876 (평일 09:00-18:00)
- 이메일: support@ncloud.com
- 커뮤니티: https://www.ncloud.com/community

### 유용한 링크
- [NCP 가이드](https://guide.ncloud-docs.com/)
- [NCP 요금 계산기](https://www.ncloud.com/charge/calc)
- [Ollama 문서](https://ollama.com/docs)
- [Next.js 문서](https://nextjs.org/docs)

---

## ✅ 배포 완료 체크리스트

- [ ] NCP 서버 생성 완료
- [ ] VPC 및 ACG 설정 완료
- [ ] 서버 초기 설정 완료 (setup_ncp_server.sh)
- [ ] DocuNova 코드 업로드 완료
- [ ] 배포 스크립트 실행 완료 (deploy_docunova.sh)
- [ ] 모든 서비스 정상 실행 확인
- [ ] 브라우저에서 접속 확인
- [ ] 파일 업로드 테스트
- [ ] AI 질의응답 테스트
- [ ] SSL 인증서 설치 (도메인이 있는 경우)
- [ ] 백업 스크립트 설정
- [ ] 모니터링 설정

---

## 🎉 배포 완료!

축하합니다! DocuNova가 성공적으로 배포되었습니다.

이제 다음을 할 수 있습니다:
- ✅ 문서 업로드 및 AI 분석
- ✅ RAG 기반 질의응답
- ✅ 벡터 검색
- ✅ 실시간 스트리밍 응답

**추가 질문이나 문제가 있으시면 위의 지원 정보를 참고하세요!**
