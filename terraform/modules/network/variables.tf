variable "profile" {
  description = "The AWS credential profile to use for authentication"
  default     = "terraform"
}

data "http" "source_ip" {
  url = "http://ipv4.icanhazip.com"
}

variable "key_pair" {
  description = "The EC2 key pair to use for SSH access"
  default     = "personal_key"
}

variable "tailscale_auth_key" {
  description = "The Tailscale auth key to authenticate instances to Tailnet"
  sensitive   = true
}

variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.2.0/24"
}

variable "az" {
  default = "us-east-1a"
}

variable "universal_tags" {
  description = "Tags to apply to all infrastructure"
}
