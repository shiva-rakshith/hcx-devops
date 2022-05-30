env = "dev"

AWS_REGION = "ap-south-1"
AWS_PROFILE = "target_hcx"
instance_type = "t3.large"

ami = "ami-0c1a7f89451184c8b"

ec2 = {
    "kafka" = "t3.large",
  }

vpc_cidr = "10.0.0.0/16"

private_subnet = [ "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24" ]

public_subnet = [ "10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24" ]
database_subnet = [ "10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24" ]
postgres_password = "SuperSecurePassword"

