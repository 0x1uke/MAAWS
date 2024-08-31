provider "aws" {
  region  = var.region
  profile = var.profile
}

resource "aws_instance" "remnux" {
  ami                         = var.remnux_ami
  instance_type               = "t2.medium"
  subnet_id                   = var.private_subnet
  private_ip                  = "10.0.2.11"
  security_groups = [var.tailscale-subnet-router]
  associate_public_ip_address = false
  key_name                    = var.key_pair

  tags = merge(var.universal_tags, {
    Name = "MAAWS-remnux"
    Created = timestamp()
  })

}
