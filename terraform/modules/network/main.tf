provider "aws" {
  region  = var.region
  profile = var.profile
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.universal_tags, {
    Name = "MAAWS-vpc"
    Created = timestamp()
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.universal_tags, {
    Name = "MAAWS-internet_gateway"
    Created = timestamp()
  })
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.az
  tags = merge(var.universal_tags, {
    Name = "MAAWS-public_subnet"
    Created = timestamp()
  })
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.az
  tags = merge(var.universal_tags, {
    Name = "MAAWS-private_subnet"
    Created = timestamp()
  })
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = merge(var.universal_tags, {
    Name = "MAAWS-nat_gateway"
    Created = timestamp()
  })

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags = merge(var.universal_tags, {
    Name = "MAAWS-eip"
    Created = timestamp()
  })
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.universal_tags, {
    Name = "MAAWS-public_route_table"
    Created = timestamp()
  })
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = merge(var.universal_tags, {
    Name = "MAAWS-private_route_table"
    Created = timestamp()
  })
}

resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "tailscale-subnet-router" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["${chomp(data.http.source_ip.response_body)}/32"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.universal_tags, {
    Name = "MAAWS-tailscale_router_sg"
    Created = timestamp()
  })
}

resource "aws_security_group" "private_subnet_sg" {
  vpc_id = aws_vpc.main.id

  # Allow all traffic from tailscale-subnet-router-sg
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    security_groups = [aws_security_group.tailscale-subnet-router.id]
  }

  tags = merge(var.universal_tags, {
    Name = "MAAWS-private_subent_sg"
    Created = timestamp()
  })
}

# EC2 Instance
resource "aws_instance" "tailscale-router" {
  ami = "ami-02c21308fed24a8ab" #Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.tailscale-subnet-router.id]
  associate_public_ip_address = true
  key_name                    = var.key_pair
  source_dest_check           = false

  tags = merge(var.universal_tags, {
    Name = "MAAWS-tailscale_router"
    Created = timestamp()
  })

  provisioner "remote-exec" {
    inline = [
      "echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf",
      "echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf",
      "sudo sysctl -p /etc/sysctl.d/99-tailscale.conf",
      "sudo yum install yum-utils -y",
      "sudo yum-config-manager --add-repo https://pkgs.tailscale.com/stable/amazon-linux/2/tailscale.repo -y",
      "sudo yum install tailscale -y",
      "sudo systemctl enable --now tailscaled",
      "sudo tailscale up --advertise-routes=${var.vpc_cidr},${var.public_subnet_cidr},${var.private_subnet_cidr} --ssh --authkey=${var.tailscale_auth_key}"
    ]

    connection {
      type  = "ssh"
      user  = "ec2-user"
      agent = true
      host  = self.public_ip
    }
  }

  # Disable source/destination checking
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_internet_gateway.igw, aws_security_group.tailscale-subnet-router]
}
