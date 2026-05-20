terraform {
  required_version = "~> 1.14.6"

  backend "s3" {
    bucket       = "three-tier-tfstate-563955855951"
    key          = "terraform.tfstate"
    region       = "ca-central-1"
    use_lockfile = true
    encrypt      = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0.0"
    }
  }
}


