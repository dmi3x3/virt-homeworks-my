provider "aws" {
  region = "eu-central-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  vm_mashines = {
    default = {}
    one = {
      "instance_type" = "t2.micro"
      "ami" = data.aws_ami.ubuntu.id
    }
    two = {
      "instance_type" = "t2.small"
      "ami" = data.aws_ami.ubuntu.id
    }
    three = {
      "instance_type" = "t2.medium"
      "ami" = data.aws_ami.ubuntu.id
    }
  }
}

locals {
  vms = {
    default = {
      two = local.vm_mashines.two
    }
    prod = {
      one   = local.vm_mashines.one
      two   = local.vm_mashines.two
      three = local.vm_mashines.three
    }
    stage = {
      one   = local.vm_mashines.one
      three = local.vm_mashines.three
    }
    }
  }



module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = local.vms[terraform.workspace]

  name = "instance-${each.key}"

  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  monitoring             = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
