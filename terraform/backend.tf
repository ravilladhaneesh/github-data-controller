terraform {
  backend "s3" {
    bucket     = "tf-state-bucket-github-viewer"
    key        = "tf-files/state/github-manager/terraform.tfstate"
    region     = "ap-south-1"
    
  }
}