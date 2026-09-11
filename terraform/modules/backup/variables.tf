variable "bucket_name" {
description = "백업 버킷 이름"
type = string
}

variable "retention_days"{
description = "보관 일수"
type = number
default = 30
}
