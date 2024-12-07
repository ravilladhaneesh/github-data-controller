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

variable "github_assume_role_arn" {
  type        = string
  description = "Arn of github assume role for post data"
}

variable "role_arn" {
  type        = string
  description = "Arn of github assume role"
}