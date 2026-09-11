output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}

output "app_private_ip" {
  value = aws_instance.app.private_ip
}

output "bucket_name"{
  value = module.backup.bucket_name
}

output "access_key_id" {
  value = module.backup.access_key_id
}

output "secret_access_key" {
  value     = module.backup.secret_access_key
  sensitive = true
}