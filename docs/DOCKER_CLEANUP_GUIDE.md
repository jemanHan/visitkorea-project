# 🧹 Docker & DB 정리 가이드

## 📋 개요

기존 Docker 컨테이너, 볼륨, 네트워크를 정리하고 새로운 설정으로 깔끔하게 시작하는 방법을 안내합니다.

---

## 🚨 정리 전 주의사항

### ⚠️ **데이터 손실 경고**
- **PostgreSQL 데이터**: 기존 데이터베이스의 모든 데이터가 삭제됩니다
- **볼륨 데이터**: Docker 볼륨에 저장된 모든 데이터가 삭제됩니다
- **컨테이너 설정**: 기존 컨테이너의 모든 설정이 초기화됩니다

### 💾 **백업 권장사항**
중요한 데이터가 있다면 정리 전에 백업하세요:
```bash
# 데이터베이스 덤프 생성
docker exec vk-postgres-$(whoami) pg_dump -U vk -d vk > backup_$(date +%Y%m%d_%H%M%S).sql

# 또는 특정 테이블만 백업
docker exec vk-postgres-$(whoami) pg_dump -U vk -d vk -t users > users_backup.sql
```

---

## 🧹 단계별 정리 방법

### **1단계: 현재 상태 확인**

```bash
# 실행 중인 컨테이너 확인
docker ps -a

# visitkorea 관련 컨테이너 확인
docker ps -a --filter "name=vk-"

# 볼륨 확인
docker volume ls | grep -E "(visitkorea|postgres|vk-)"

# 네트워크 확인
docker network ls | grep visitkorea
```

### **2단계: 서비스 중지**

```bash
# Docker Compose로 실행된 서비스 중지
docker compose down

# 또는 특정 서비스만 중지
docker compose stop postgres backend prisma-studio
```

### **3단계: 컨테이너 정리**

```bash
# visitkorea 관련 컨테이너 모두 중지
docker stop $(docker ps -q --filter "name=vk-") 2>/dev/null || true

# visitkorea 관련 컨테이너 모두 삭제
docker rm $(docker ps -aq --filter "name=vk-") 2>/dev/null || true

# 또는 개별적으로 삭제
docker rm vk-postgres-$(whoami) 2>/dev/null || true
docker rm vk-backend-$(whoami) 2>/dev/null || true
docker rm vk-prisma-studio-$(whoami) 2>/dev/null || true
```

### **4단계: 볼륨 정리**

```bash
# visitkorea 관련 볼륨 삭제
docker volume rm $(docker volume ls -q --filter "name=visitkorea") 2>/dev/null || true
docker volume rm $(docker volume ls -q --filter "name=postgres") 2>/dev/null || true
docker volume rm $(docker volume ls -q --filter "name=vk-") 2>/dev/null || true

# 또는 개별적으로 삭제
docker volume rm visitkorea_postgres_data 2>/dev/null || true
docker volume rm vk-postgres-data 2>/dev/null || true
```

### **5단계: 네트워크 정리**

```bash
# visitkorea 관련 네트워크 삭제
docker network rm visitkorea-network 2>/dev/null || true
docker network rm visitkorea-network-$(whoami) 2>/dev/null || true
```

### **6단계: 이미지 정리 (선택사항)**

```bash
# 사용하지 않는 이미지 삭제
docker image prune -f

# visitkorea 관련 이미지 삭제
docker rmi $(docker images -q --filter "reference=*visitkorea*") 2>/dev/null || true
docker rmi $(docker images -q --filter "reference=*vk-*") 2>/dev/null || true
```

---

## 🔄 완전 정리 (강력한 방법)

### **방법 A: Docker Compose로 완전 정리**
```bash
# 모든 서비스 중지 및 삭제
docker compose down -v --remove-orphans

# 볼륨까지 모두 삭제
docker compose down -v --remove-orphans --rmi all
```

### **방법 B: Docker 시스템 전체 정리**
```bash
# 사용하지 않는 모든 리소스 정리
docker system prune -f

# 이미지까지 모두 정리
docker system prune -a -f

# 볼륨까지 모두 정리 (주의: 모든 데이터 삭제)
docker system prune -a -f --volumes
```

### **방법 C: 수동으로 모든 것 정리**
```bash
# 1. 모든 컨테이너 중지 및 삭제
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true

# 2. 모든 볼륨 삭제
docker volume rm $(docker volume ls -q) 2>/dev/null || true

# 3. 모든 네트워크 삭제 (기본 네트워크 제외)
docker network rm $(docker network ls -q --filter "type=custom") 2>/dev/null || true

# 4. 모든 이미지 삭제
docker rmi $(docker images -q) 2>/dev/null || true
```

---

## 🚀 정리 후 새로운 시작

### **1. 환경변수 파일 확인**
```bash
# 새로운 .env 파일이 준비되어 있는지 확인
ls -la apps/backend/.env*

# 필요시 기존 설정 백업
cp apps/backend/.env.local apps/backend/.env.local.backup 2>/dev/null || true
```

### **2. 새로운 설정으로 시작**
```bash
# 1) DB 먼저 시작
docker compose up -d db

# 2) Prisma 준비
docker compose run --rm backend npx prisma generate
docker compose run --rm backend npx prisma migrate deploy

# 3) 앱 띄우기
docker compose up -d backend
docker compose --profile dev up -d prisma-studio
```

### **3. 서비스 확인**
```bash
# 컨테이너 상태 확인
docker compose ps

# 로그 확인
docker compose logs -f

# 서비스 접속 테스트
curl http://localhost:3002/health
```

---

## 🔍 정리 확인 방법

### **정리 완료 확인**
```bash
# 컨테이너가 모두 정리되었는지 확인
docker ps -a | grep -E "(vk-|visitkorea)" || echo "✅ 모든 컨테이너 정리 완료"

# 볼륨이 모두 정리되었는지 확인
docker volume ls | grep -E "(vk-|visitkorea|postgres)" || echo "✅ 모든 볼륨 정리 완료"

# 네트워크가 정리되었는지 확인
docker network ls | grep visitkorea || echo "✅ 모든 네트워크 정리 완료"
```

### **새로운 설정 확인**
```bash
# 새로운 컨테이너가 정상적으로 실행되는지 확인
docker compose ps

# 데이터베이스 연결 확인
docker compose exec db psql -U vk -d visitkorea -c "\dt"

# 백엔드 API 확인
curl http://localhost:3002/health
```

---

## 🆘 문제 해결

### **정리 중 오류 발생 시**
```bash
# 강제로 컨테이너 삭제
docker rm -f $(docker ps -aq --filter "name=vk-") 2>/dev/null || true

# 강제로 볼륨 삭제
docker volume rm -f $(docker volume ls -q --filter "name=vk-") 2>/dev/null || true

# Docker 데몬 재시작 (필요시)
sudo systemctl restart docker
```

### **권한 문제 발생 시**
```bash
# Docker 권한 확인
sudo usermod -aG docker $USER

# 로그아웃 후 재로그인 또는
newgrp docker
```

### **포트 충돌 발생 시**
```bash
# 포트 사용 중인 프로세스 확인
sudo lsof -i :5432
sudo lsof -i :3002
sudo lsof -i :5555

# 프로세스 종료
sudo kill -9 <PID>
```

---

## 📝 정리 체크리스트

### **정리 전 체크리스트**
- [ ] 중요한 데이터 백업 완료
- [ ] 현재 실행 중인 서비스 확인
- [ ] 정리할 리소스 목록 확인

### **정리 중 체크리스트**
- [ ] 서비스 중지 완료
- [ ] 컨테이너 삭제 완료
- [ ] 볼륨 삭제 완료
- [ ] 네트워크 삭제 완료
- [ ] 이미지 삭제 완료 (선택사항)

### **정리 후 체크리스트**
- [ ] 새로운 설정으로 서비스 시작
- [ ] 데이터베이스 연결 확인
- [ ] 백엔드 API 동작 확인
- [ ] Prisma Studio 접속 확인

---

## 💡 팁

### **정리 스크립트 생성**
```bash
# cleanup.sh 스크립트 생성
cat > cleanup.sh << 'EOF'
#!/bin/bash
echo "🧹 Docker & DB 정리 시작..."

# 서비스 중지
docker compose down

# 컨테이너 정리
docker stop $(docker ps -q --filter "name=vk-") 2>/dev/null || true
docker rm $(docker ps -aq --filter "name=vk-") 2>/dev/null || true

# 볼륨 정리
docker volume rm $(docker volume ls -q --filter "name=vk-") 2>/dev/null || true

# 네트워크 정리
docker network rm visitkorea-network 2>/dev/null || true

echo "✅ 정리 완료!"
EOF

chmod +x cleanup.sh
```

### **자동 정리 후 시작 스크립트**
```bash
# fresh-start.sh 스크립트 생성
cat > fresh-start.sh << 'EOF'
#!/bin/bash
echo "🧹 기존 환경 정리 중..."
./cleanup.sh

echo "🚀 새로운 환경 시작 중..."
docker compose up -d db
docker compose run --rm backend npx prisma generate
docker compose run --rm backend npx prisma migrate deploy
docker compose up -d backend
docker compose --profile dev up -d prisma-studio

echo "✅ 새로운 환경 시작 완료!"
echo "🌐 백엔드: http://localhost:3002"
echo "🌐 Prisma Studio: http://localhost:5555"
EOF

chmod +x fresh-start.sh
```

---

*마지막 업데이트: 2024년 9월 4일*
