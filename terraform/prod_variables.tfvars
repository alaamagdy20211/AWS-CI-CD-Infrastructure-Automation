    region = "eu-central-1"
    ami = "ami-036bdae36143a955f"
    instance_type = "t3.micro"
     vpc_icdr ="10.0.0.0/16"

   subnets = [
  {
    name = "public_subnet_1"
    cidr = "10.0.1.0/24"
    type = "public"
    az   = "eu-central-1a"
  },
  {
    name = "public_subnet_2"
    cidr = "10.0.2.0/24"
    type = "public"
    az   = "eu-central-1b"
  },
  {
    name = "priv_subnet_1"
    cidr = "10.0.11.0/24"
    type = "private"
    az   = "eu-central-1a"
  },
  {
    name = "priv_subnet_2"
    cidr = "10.0.12.0/24"
    type = "private"
    az   = "eu-central-1b"
  }
]