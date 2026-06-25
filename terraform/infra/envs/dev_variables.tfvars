    region = "us-east-1"
    instance_type = "c7i-flex.large"
    vpc_icdr = "10.0.0.0/16"


subnets = [
  {
    name = "public_subnet_1"
    cidr = "10.0.1.0/24"
    type = "public"
    az   = "us-east-1a"
  },
  {
    name = "public_subnet_2"
    cidr = "10.0.2.0/24"
    type = "public"
    az   = "us-east-1b"
  },
  {
    name = "priv_subnet_1"
    cidr = "10.0.11.0/24"
    type = "private"
    az   = "us-east-1a"
  },
  {
    name = "priv_subnet_2"
    cidr = "10.0.12.0/24"
    type = "private"
    az   = "us-east-1b"
  }
]