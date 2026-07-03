output "ec2_public_ip" {
  description = "Public IP address of the CI/CD deployment server"
  value       = aws_instance.cicd_server.public_ip
}

output "application_url" {
  description = "Application URL after GitHub Actions deployment"
  value       = "http://${aws_instance.cicd_server.public_ip}:8081"
}

output "ssh_command" {
  description = "SSH command for MobaXterm or terminal"
  value       = "ssh -i <your-private-key.pem> ubuntu@${aws_instance.cicd_server.public_ip}"
}
