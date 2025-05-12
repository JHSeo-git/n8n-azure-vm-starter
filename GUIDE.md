## n8n-vm-template

```
RESOURCE_GROUP="rg-aoai-kc-aipg-dev"
LOCATION="koreacentral"
VM_NAME="axpg-n8n"
ADMIN_USERNAME="n8nadmin"
DNS_PREFIX="n8n-$(date +%s | cut -c6-10)"
```

1. ./deploy.sh 실행
   1. vnet: 10.72.0.0/16
   2. subnet: 10.72.0.0/24
2. scp 사용하여 docker-compose.yml, setup.sh 파일 이동
3. ssh 접속하여 ./setup.sh 실행
4. docker 설치 후 ssh 재접속
5. docker compose 실행
   1. vm에서 registry 로그인: docker login -u axpg-token -p ... aoaiaiplayground.azurecr.io
6. 실행 후 docker 접속
   1. vm내 docker conatiner에서 registry 로그인: docker login -u axpg-token -p ... aoaiaiplayground.azurecr.io

생성되는 리소스

- VM: axpg-vm
  - nic, nsg
- public ip: axpg-vm-ip
- vnet: axpg-vm-vnet
- subnet: default

## Application Gateway + Peering

기존 aipg agw(`agw-aoai-kc-az1-aipg-dev-01`) vnet과 n8n-vm에서 사용하는 vnet peering
aipg agw에 라우팅 규칙 추가

1. peering: axpg-n8n-vnet <-> vnet-aoai-kc-aipg-dev-01
2. 백엔드 풀: vm private ip
3. 백엔드 설정: http 5678포트로 전송
4. 리스너 + Rule:
   1. n8n-dev.aipg.lgcns.com 80 -> 443 리다이렉트
   2. n8n-dev.aipg.lgcns.com 443 -> 백엔드 풀, 설정 연결
5. 상태 프로프:
   1. 호스트: n8n-dev.aipg.lgcns.com
   2. 경로: /

## 프라이빗 DNS

1. 프라이빗 DNS 설정: `*.aipg.lgcns.com` 에 서브도메인 추가
   1. n8n-dev
   2. 기존 agw(라우팅 추가한 agw ip): 10.62.193.70

## DB - Postgresql

1. postgresql 생성 시 vm vnet과 같은 곳에 subnet을 생성해서 연결
2. 계정 생성 시 사용했던 값들 나중에 참고를 위해 저장
3. postgresql 리소스 생성 후 n8n db 생성

## trouble shooting

### no pg_hba.conf entry for host ...

Azure RDS 연결 시 SSL 연결만 가능함

- DB_POSTGRESDB_SSL_ENABLED=true 설정 필요
