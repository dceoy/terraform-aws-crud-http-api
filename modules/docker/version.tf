terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.98.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.5.0"
    }
  }
}
