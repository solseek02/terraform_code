# AWS Provider 설정
provider "aws" {
  region = var.aws_region
}

# VPC-a (온프레미스 환경 시뮬레이션)
module "vpc_a" {
  source = "./modules/vpc"

  name = "vpc-a"
  cidr = "30.0.0.0/16"
  azs  = ["ap-northeast-2a"]
  
  public_subnets = ["30.0.1.0/24"]
  
  tags = {
    Environment = "on-premise-simulation"
    Project     = "solseek"
  }
}

# VPC-b (AWS 클라우드 환경)
module "vpc_b" {
  source = "./modules/vpc"

  name = "vpc-b"
  cidr = "40.0.0.0/16"
  azs  = ["ap-northeast-2a", "ap-northeast-2b"]
  
  public_subnets  = ["40.0.1.0/24", "40.0.2.0/24"]
  private_subnets = ["40.0.11.0/24", "40.0.12.0/24"]
  
  enable_nat_gateway = true
  single_nat_gateway = true
  
  tags = {
    Environment = "cloud"
    Project     = "solseek"
  }
}

# VPC 피어링 연결
resource "aws_vpc_peering_connection" "vpc_peering" {
  vpc_id      = module.vpc_a.vpc_id
  peer_vpc_id = module.vpc_b.vpc_id
  auto_accept = true

  tags = {
    Name = "vpc-a-to-vpc-b"
  }
}

# VPC 피어링 라우팅 테이블 업데이트
resource "aws_route" "vpc_a_to_vpc_b" {
  route_table_id            = module.vpc_a.public_route_table_ids[0]
  destination_cidr_block    = module.vpc_b.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}

resource "aws_route" "vpc_b_to_vpc_a" {
  route_table_id            = module.vpc_b.public_route_table_ids[0]
  destination_cidr_block    = module.vpc_a.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}

# 보안 그룹
resource "aws_security_group" "all_sg" {
  name        = "all-sg"
  description = "Allow all traffic"
  vpc_id      = module.vpc_b.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "all-sg"
  }
}

# ROSA 클러스터 생성
resource "aws_iam_role" "rosa_cluster_role" {
  name = "rosa-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rosa_cluster_policy" {
  role       = aws_iam_role.rosa_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# CloudWatch 로그 그룹
resource "aws_cloudwatch_log_group" "rosa_logs" {
  name              = "/aws/rosa/cluster"
  retention_in_days = 30
}

# S3 버킷 (로그 저장용)
resource "aws_s3_bucket" "logs_bucket" {
  bucket = "solseek-logs-${var.environment}"
}

resource "aws_s3_bucket_versioning" "logs_bucket_versioning" {
  bucket = aws_s3_bucket.logs_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Lambda 함수 (로그 처리용)
resource "aws_lambda_function" "log_processor" {
  filename         = "lambda_function.zip"
  function_name    = "log-processor"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 30
  memory_size     = 128

  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.logs_bucket.id
    }
  }
}

# Lambda IAM 역할
resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_s3" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
} 