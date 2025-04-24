output "vpc_id" {
  description = "생성된 VPC의 ID"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "VPC의 CIDR 블록"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "퍼블릭 서브넷 ID 목록"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "프라이빗 서브넷 ID 목록"
  value       = aws_subnet.private[*].id
}

output "public_route_table_ids" {
  description = "퍼블릭 라우팅 테이블 ID 목록"
  value       = [aws_route_table.public.id]
}

output "private_route_table_ids" {
  description = "프라이빗 라우팅 테이블 ID 목록"
  value       = var.enable_nat_gateway ? [aws_route_table.private[0].id] : []
}

output "nat_gateway_ids" {
  description = "NAT 게이트웨이 ID 목록"
  value       = var.enable_nat_gateway ? aws_nat_gateway.this[*].id : []
}

output "nat_public_ips" {
  description = "NAT 게이트웨이의 퍼블릭 IP 목록"
  value       = var.enable_nat_gateway ? aws_eip.nat[*].public_ip : []
} 