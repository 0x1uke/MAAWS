variable "profile" {
  description = "The AWS credential profile to use for authentication"
  default     = "terraform"
}

variable "region" {
  default = "us-east-1"
}

variable "private_subnet" {
  description = "The private subnet built by network module"
}

variable "tailscale-subnet-router" {
  description = "The tailscale-subnet-router security group built by network module"
}

variable "key_pair" {
  description = "The EC2 key pair to use for SSH access"
  default     = "personal_key"
}

variable "flarevm_ami" {
  description = "The AMI ID to be used for FLAREVM"
}

variable "universal_tags" {
  description = "Tags to apply to all infrastructure"
}
