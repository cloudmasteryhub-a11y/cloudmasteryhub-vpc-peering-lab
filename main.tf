############################
# AMIs (Amazon Linux 2023)
############################
data "aws_ami" "al2023_mumbai" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["amazon"]
}

data "aws_ami" "al2023_virginia" {
  provider    = aws.virginia
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["amazon"]
}

############################
# VPC-A (Mumbai)
############################
resource "aws_vpc" "vpc_a" {
  cidr_block           = var.vpc_a_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.project_name}-vpc-a-mumbai" }
}

resource "aws_internet_gateway" "igw_a" {
  vpc_id = aws_vpc.vpc_a.id
  tags   = { Name = "${var.project_name}-igw-a" }
}

resource "aws_subnet" "subnet_a_public" {
  vpc_id                  = aws_vpc.vpc_a.id
  cidr_block              = var.subnet_a_public_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.region_mumbai}a"
  tags                    = { Name = "${var.project_name}-subnet-a1-public" }
}

resource "aws_subnet" "subnet_a_private" {
  vpc_id            = aws_vpc.vpc_a.id
  cidr_block        = var.subnet_a_private_cidr
  availability_zone = "${var.region_mumbai}b"
  tags              = { Name = "${var.project_name}-subnet-a2-private" }
}
resource "aws_subnet" "subnet_a_private_3" {
  vpc_id                  = aws_vpc.vpc_a.id
  cidr_block              = var.subnet_a3_private_cidr
  availability_zone       = var.az_mumbai_private_3
  map_public_ip_on_launch = false

  tags = { Name = "${var.project_name}-subnet-a3-private" }
}


resource "aws_route_table" "rt_a_public" {
  vpc_id = aws_vpc.vpc_a.id
  tags   = { Name = "${var.project_name}-rt-a-public" }
}

resource "aws_route" "rt_a_public_default" {
  route_table_id         = aws_route_table.rt_a_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_a.id
}

resource "aws_route_table_association" "rt_a_public_assoc" {
  subnet_id      = aws_subnet.subnet_a_public.id
  route_table_id = aws_route_table.rt_a_public.id
}

resource "aws_route_table" "rt_a_private" {
  vpc_id = aws_vpc.vpc_a.id
  tags   = { Name = "${var.project_name}-rt-a-private" }
}

resource "aws_route_table_association" "rt_a_private_assoc" {
  subnet_id      = aws_subnet.subnet_a_private.id
  route_table_id = aws_route_table.rt_a_private.id
}

############################
# VPC-B (N. Virginia)
############################
resource "aws_vpc" "vpc_b" {
  provider             = aws.virginia
  cidr_block           = var.vpc_b_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${var.project_name}-vpc-b-virginia" }
}

resource "aws_subnet" "subnet_b1_private" {
  provider          = aws.virginia
  vpc_id            = aws_vpc.vpc_b.id
  cidr_block        = var.subnet_b1_private_cidr
  availability_zone = "${var.region_virginia}a"
  tags              = { Name = "${var.project_name}-subnet-b1-private" }
}

resource "aws_subnet" "subnet_b2_private" {
  provider          = aws.virginia
  vpc_id            = aws_vpc.vpc_b.id
  cidr_block        = var.subnet_b2_private_cidr
  availability_zone = "${var.region_virginia}b"
  tags              = { Name = "${var.project_name}-subnet-b2-private" }
}
resource "aws_subnet" "subnet_b3_private" {
  provider                = aws.virginia
  vpc_id                  = aws_vpc.vpc_b.id
  cidr_block              = var.subnet_b3_private_cidr
  availability_zone       = var.az_virginia_private_3
  map_public_ip_on_launch = false

  tags = { Name = "${var.project_name}-subnet-b3-private" }
}
resource "aws_route_table" "rt_b_private" {
  provider = aws.virginia
  vpc_id   = aws_vpc.vpc_b.id
  tags     = { Name = "${var.project_name}-rt-b-private" }
}
resource "aws_route_table_association" "rt_b1_assoc" {
  provider       = aws.virginia
  subnet_id      = aws_subnet.subnet_b1_private.id
  route_table_id = aws_route_table.rt_b_private.id
}

resource "aws_route_table_association" "rt_b2_assoc" {
  provider       = aws.virginia
  subnet_id      = aws_subnet.subnet_b2_private.id
  route_table_id = aws_route_table.rt_b_private.id
}
resource "aws_route_table_association" "rt_a_private_3_assoc" {
  subnet_id      = aws_subnet.subnet_a_private_3.id
  route_table_id = aws_route_table.rt_a_private.id
}
resource "aws_route_table_association" "rt_b3_assoc" {
  provider       = aws.virginia
  subnet_id      = aws_subnet.subnet_b3_private.id
  route_table_id = aws_route_table.rt_b_private.id
}
############################
# Inter-Region VPC Peering
############################
resource "aws_vpc_peering_connection" "pcx" {
  vpc_id      = aws_vpc.vpc_a.id
  peer_vpc_id = aws_vpc.vpc_b.id
  peer_region = var.region_virginia
  auto_accept = false
  tags        = { Name = "${var.project_name}-pcx-a-to-b" }
}

resource "aws_vpc_peering_connection_accepter" "pcx_accept" {
  provider                  = aws.virginia
  vpc_peering_connection_id = aws_vpc_peering_connection.pcx.id
  auto_accept               = true
  tags                      = { Name = "${var.project_name}-pcx-accept" }
}

resource "aws_vpc_peering_connection_options" "pcx_options_requester" {
  vpc_peering_connection_id = aws_vpc_peering_connection.pcx.id

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  depends_on = [aws_vpc_peering_connection_accepter.pcx_accept]
}

resource "aws_vpc_peering_connection_options" "pcx_options_accepter" {
  provider                  = aws.virginia
  vpc_peering_connection_id = aws_vpc_peering_connection.pcx.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  depends_on = [aws_vpc_peering_connection_accepter.pcx_accept]
}

############################
# Routes for Peering
############################
resource "aws_route" "rt_a_private_to_b" {
  route_table_id            = aws_route_table.rt_a_private.id
  destination_cidr_block    = var.vpc_b_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.pcx.id
  depends_on                = [aws_vpc_peering_connection_accepter.pcx_accept]
}

resource "aws_route" "rt_a_public_to_b" {
  route_table_id            = aws_route_table.rt_a_public.id
  destination_cidr_block    = var.vpc_b_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.pcx.id
  depends_on                = [aws_vpc_peering_connection_accepter.pcx_accept]
}

resource "aws_route" "rt_b_to_a" {
  provider                  = aws.virginia
  route_table_id            = aws_route_table.rt_b_private.id
  destination_cidr_block    = var.vpc_a_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.pcx.id
  depends_on                = [aws_vpc_peering_connection_accepter.pcx_accept]
}

############################
# Security Groups
############################
resource "aws_security_group" "sg_bastion" {
  name        = "${var.project_name}-sg-bastion"
  description = "Allow SSH from my IP to bastion"
  vpc_id      = aws_vpc.vpc_a.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-sg-bastion" }
}

resource "aws_security_group" "sg_private_a" {
  name        = "${var.project_name}-sg-private-a"
  description = "Private EC2-A rules"
  vpc_id      = aws_vpc.vpc_a.id

  ingress {
    description = "SSH from Bastion subnet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.subnet_a_public_cidr]
  }

  ingress {
    description = "ICMP from VPC-B (optional)"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_b_cidr]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-sg-private-a" }
}

resource "aws_security_group" "sg_private_b" {
  provider    = aws.virginia
  name        = "${var.project_name}-sg-private-b"
  description = "Private EC2-B rules"
  vpc_id      = aws_vpc.vpc_b.id

  ingress {
    description = "SSH from VPC-A"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_a_cidr]
  }

  ingress {
    description = "ICMP from VPC-A (optional)"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_a_cidr]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-sg-private-b" }
}

############################
# EC2 Instances
############################
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.al2023_mumbai.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnet_a_public.id
  vpc_security_group_ids      = [aws_security_group.sg_bastion.id]
  key_name                    = var.key_name_bastion_mumbai
  associate_public_ip_address = true

  tags = { Name = "${var.project_name}-bastion-mumbai" }
}

resource "aws_instance" "ec2_a_private" {
  ami                    = data.aws_ami.al2023_mumbai.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet_a_private.id
  vpc_security_group_ids = [aws_security_group.sg_private_a.id]
  key_name               = var.key_name_private_mumbai

  tags = { Name = "${var.project_name}-ec2-a-private" }
}

resource "aws_instance" "ec2_b_private" {
  provider               = aws.virginia
  ami                    = data.aws_ami.al2023_virginia.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet_b1_private.id
  vpc_security_group_ids = [aws_security_group.sg_private_b.id]
  key_name               = var.key_name_virginia

  tags = { Name = "${var.project_name}-ec2-b-private" }
}
resource "aws_instance" "ec2_a_private_3" {
  ami                    = data.aws_ami.al2023_mumbai.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet_a_private_3.id
  vpc_security_group_ids = [aws_security_group.sg_private_a.id]
  key_name               = var.key_name_private_mumbai

  tags = { Name = "${var.project_name}-ec2-a-private-3" }
}
resource "aws_instance" "ec2_b_private_3" {
  provider               = aws.virginia
  ami                    = data.aws_ami.al2023_virginia.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet_b3_private.id
  vpc_security_group_ids = [aws_security_group.sg_private_b.id]
  key_name               = var.key_name_virginia

  tags = { Name = "${var.project_name}-ec2-b-private-3" }
}
