terraform {
  backend "s3" {
    bucket     = "github-repo-manager"
    key        = "tf-files/state/github-manager/terraform.tfstate"
    region     = "ap-south-1"
  }
}