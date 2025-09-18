data "aws_availability_zones" "available" {}

resource "aws_vpc" "emr_studio_vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "emr-studio-vpc" }
}

resource "aws_subnet" "emr_studio_subnet" {
  count             = 2 # EMR Studio requires at least two subnets
  vpc_id            = aws_vpc.emr_studio_vpc.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags              = { Name = "emr-studio-subnet-${count.index}" }
}

resource "aws_security_group" "emr_studio_sg" {
  name        = "emr-studio-sg"
  description = "Allow all outbound traffic for EMR Studio"
  vpc_id      = aws_vpc.emr_studio_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "emr-studio-sg" }
}
