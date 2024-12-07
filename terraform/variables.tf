variable "accountId" {
  type = string
}

variable "region" {
  type = string
}

variable "local_user_arn" {
  type        = string
  description = "A local testing user arn"
}


variable "put_data_role_arn" {
  type        = string
  description = "Arn of github put data role"
}