resource "aws_vpc" "trfm_vpc" {
  cidr_block           = "10.40.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "trfm_public_subnet" {
  vpc_id                  = aws_vpc.trfm_vpc.id
  cidr_block              = "10.40.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "dev-public"
  }
}

resource "aws_internet_gateway" "trfm_internet_gateway" {
  vpc_id = aws_vpc.trfm_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "trfm_public_rt" {
  vpc_id = aws_vpc.trfm_vpc.id

  tags = {
    Name = "dev-rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.trfm_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.trfm_internet_gateway.id
}

resource "aws_route_table_association" "trfm_public_assoc" {
  subnet_id      = aws_subnet.trfm_public_subnet.id
  route_table_id = aws_route_table.trfm_public_rt.id
}

resource "aws_security_group" "trfm_sg" {
  name        = "dev_sg"
  description = "dev security group"
  vpc_id      = aws_vpc.trfm_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_key_pair" "trfm_auth" {
  key_name   = "trfmkey"
  public_key = file("~/.ssh/trfmkey.pub")
}

resource "aws_instance" "trfm_node" {
  instance_type          = "m5.large"
  ami                    = "ami-0af9ac10a534a823b"
  key_name               = aws_key_pair.trfm_auth.id
  vpc_security_group_ids = ["sg-064e7f4ecb3db70fc"]
  subnet_id              = "subnet-025a139275c207e84"
  user_data              = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }

}
#resource "aws_s3_bucket" "example" {
#  bucket = "my-tf-test-bucket-2508"
#}