provider "aws" {
  region     = var.aws_region
  access_key = "AKIA4MTWMO4EZIVGYM7A"
  secret_key = "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"

  default_tags {
    tags = {
      Environment = terraform.workspace
      Owner       = "Content-Engine"
      Provisioned = "Terraform"
    }
  }

}