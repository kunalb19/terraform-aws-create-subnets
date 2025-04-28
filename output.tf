output "subnet_id" {
  description = "The ID of the subnet"
  value       = [
    for subnet in aws_subnet.aws_subnet : subnet.id
  ]
}