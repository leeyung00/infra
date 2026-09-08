output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}

output "app_private_ip" {
  value = aws_instance.app.private_ip
}
