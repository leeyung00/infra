resource "aws_s3_bucket" "backup"{
bucket = var.bucket_name
tags = {Name = "homelab-backup"}
}

resource
