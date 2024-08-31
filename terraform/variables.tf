variable "profile" {
  description = "The AWS credential profile to use for authentication"
  default     = "terraform"
}

variable "region" {
  default = "us-east-1"
}

variable "az" {
  description = "The accessibility zone for the lab network"
  default     = "us-east-1a"
}

variable "key_pair" {
  description = "The EC2 key pair to use for SSH access"
}

variable "tailscale_auth_key" {
  description = "The Tailscale auth key to authenticate instances to Tailnet"
  sensitive   = true
}

variable "flarevm_ami" {
  description = "The AMI ID to be used for FLAREVM"
}

variable "remnux_ami" {
  description = "The AMI ID to be used for the REMNUX VM"
}

variable "universal_tags" {
  description = "Tags to apply to all resources"
  type = map(string)
  default = {
    Project   = "MAAWS"
    CreatedBy = "terraform"
  }
}