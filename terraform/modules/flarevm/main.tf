provider "aws" {
  region  = var.region
  profile = var.profile
}

resource "aws_instance" "flarevm" {
  ami                         = var.flarevm_ami
  instance_type               = "t2.medium"
  subnet_id                   = var.private_subnet
  private_ip                  = "10.0.2.10"
  security_groups = [var.tailscale-subnet-router]
  associate_public_ip_address = false
  key_name                    = var.key_pair

  tags = merge(var.universal_tags, {
    Name = "MAAWS-flarevm"
    Created = timestamp()
  })

}
