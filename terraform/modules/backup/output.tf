output "bucket_name"{
value = aws_s3_bucket.backup.id
}
output "access_key_id"{
value = aws_iam_access_key.backup.id
}

output "secret_access_key"{
value = aws_iam_access_key.backup.secret
sensitive = true
}
