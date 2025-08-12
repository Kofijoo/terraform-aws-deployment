output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "web_server_public_ips" {
  description = "Public IP addresses of web servers"
  value       = module.web_server.public_ips
}

output "web_server_urls" {
  description = "URLs of web servers"
  value       = [for ip in module.web_server.public_ips : "http://${ip}"]
}

output "db_server_private_ips" {
  description = "Private IP addresses of database servers"
  value       = module.db_server.private_ips
}

output "nat_gateway_public_ips" {
  description = "Public IPs of NAT Gateways"
  value       = module.vpc.nat_public_ips
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_url" {
  description = "URL of the Application Load Balancer"
  value       = "http://${module.alb.alb_dns_name}"
}