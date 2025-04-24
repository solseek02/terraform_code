variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "environment" {
  description = "환경 (dev, prod 등)"
  type        = string
  default     = "dev"
}

variable "vpc_a_cidr" {
  description = "VPC-a의 CIDR 블록"
  type        = string
  default     = "30.0.0.0/16"
}

variable "vpc_b_cidr" {
  description = "VPC-b의 CIDR 블록"
  type        = string
  default     = "40.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "퍼블릭 서브넷 CIDR 블록"
  type        = list(string)
  default     = ["40.0.1.0/24", "40.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "프라이빗 서브넷 CIDR 블록"
  type        = list(string)
  default     = ["40.0.11.0/24", "40.0.12.0/24"]
}

variable "availability_zones" {
  description = "사용할 가용 영역"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2b"]
}

variable "tags" {
  description = "리소스에 적용할 태그"
  type        = map(string)
  default = {
    Project     = "solseek"
    Environment = "dev"
  }
} 