# AWS ROSA 인프라 자동화

이 프로젝트는 AWS 환경에서 ROSA(Red Hat OpenShift Service on AWS) 클러스터를 구축하기 위한 Terraform 코드를 제공합니다.

## 주요 기능

- VPC 및 서브넷 구성
  - VPC-a: 온프레미스 환경 시뮬레이션
  - VPC-b: AWS 클라우드 환경
- VPC 피어링 연결
- 보안 그룹 설정
- ROSA 클러스터 구성
- CloudWatch 로그 그룹
- S3 버킷 (로그 저장용)
- Lambda 함수 (로그 처리용)

## 사전 요구사항

- AWS CLI 설치 및 구성
- Terraform 설치 (v1.0.0 이상)
- AWS 계정 및 적절한 권한

## 설치 방법

1. 저장소 클론
```bash
git clone https://github.com/your-username/terraform-aws-rosa.git
cd terraform-aws-rosa
```

2. Terraform 초기화
```bash
terraform init
```

3. 실행 계획 확인
```bash
terraform plan
```

4. 인프라 배포
```bash
terraform apply
```

## 변수 설정

`terraform.tfvars` 파일을 생성하여 다음 변수들을 설정할 수 있습니다:

```hcl
aws_region = "ap-northeast-2"
environment = "dev"
vpc_a_cidr = "30.0.0.0/16"
vpc_b_cidr = "40.0.0.0/16"
```

## 모듈 구조

```
terraform-aws-rosa/
├── main.tf
├── variables.tf
├── outputs.tf
└── modules/
    └── vpc/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## 보안 고려사항

- VPC 피어링을 통한 안전한 통신
- 보안 그룹을 통한 네트워크 접근 제어
- IAM 역할 및 정책을 통한 권한 관리
- CloudWatch 및 S3를 통한 로그 관리

## 모니터링

- CloudWatch 로그 그룹을 통한 로그 수집
- Lambda 함수를 통한 로그 처리 및 S3 저장
- S3 버킷을 통한 로그 보관

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 기여 방법

1. 이슈 생성
2. 브랜치 생성
3. 변경사항 커밋
4. Pull Request 생성 