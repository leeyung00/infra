resource "aws_s3_bucket" "backup"{
bucket = var.bucket_name
tags = {Name = "homelab-backup"}
}

resource "aws_s3_bucket_public_access_block" "backup" {
bucket = aws_s3_bucket.backup.id
block_public_acls = true
block_public_policy = true
ignore_public_buckets = true
restrict_public_buckets = true 
}

resource "aws_s3_bucket_versioning" "backup"{
bucket = aws_s3_bucket.backup.id
versioning_configuration{ status = "Enabled"}
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backup"{
bucket = aws_s3_bucket.backup.id
rule{
apply_server_side_encryption_by_default{
sse_algorithm = "AES256"
}
}
}

resource "aws_s3_bucket_lifecycle_configuration" "backup"{
bucket = aws_s3_bucket.backup.id
rule{
id = "expire-old-backups"
status = "Enabled"

filter{prefix = "mysql/"}
expiration{days = var.retention_days}
noncurrnet_version_expiration{noncurrnet_days = 7}
}
}

resource "aws_iam_user" "backup"{
name = "homelab-backup"
tags = {Name = "homelab-backup"}
}

resource "aws_iam_policy" "backup"{
name = "homelab-backup-policy"
description = "백업 최소 권한"
policy = jsonencode({
Version = "2012-10-17"
Statement = [
{
Effect = "Allow"
Action = ["s3:PutObject"]
Resource = "${aws_s3_bucket.backup.arn}/mysql/*"
},
{
Effect = "Allow"
Action = ["s3:ListBucket"]
Resource = aws_s3_bucket.backup.arn
Condition = {
StringLike = {
"s3:prefix" = ["mysql/*"]
}
}
}
]
})
}

resource "aws_iam_user_policy_attachment" "backup"{
user = aws_iam_user.backup.name
policy_arn = aws_iam_policy.backup.arn
}

resource "aws_iam_access_key" "backup"{
user = aws_iam_user.backup.name
}
