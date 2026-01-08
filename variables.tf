variable "project_name" {
  type        = string
  description = "Used for naming resources"
  default     = "cmh-vpc-peering"
}

variable "region_mumbai" {
  type    = string
  default = "ap-south-1"
}

variable "region_virginia" {
  type    = string
  default = "us-east-1"
}

variable "vpc_a_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "subnet_a_public_cidr" {
  type    = string
  default = "10.10.1.0/24"
}

variable "subnet_a_private_cidr" {
  type    = string
  default = "10.10.2.0/24"
}

variable "vpc_b_cidr" {
  type    = string
  default = "172.1.0.0/16"
}

variable "subnet_b1_private_cidr" {
  type    = string
  default = "172.1.1.0/24"
}

variable "subnet_b2_private_cidr" {
  type    = string
  default = "172.1.2.0/24"
}
# NEW: Additional private subnet CIDR for VPC-A (Mumbai)
variable "subnet_a3_private_cidr" {
  type        = string
  default     = "10.10.3.0/24"
  description = "Additional private subnet CIDR for VPC-A (Mumbai)"
}

# NEW: Additional private subnet CIDR for VPC-B (Virginia)
variable "subnet_b3_private_cidr" {
  type        = string
  default     = "172.1.3.0/24"
  description = "Additional private subnet CIDR for VPC-B (Virginia)"
}

# NEW: AZ for Mumbai new private subnet
variable "az_mumbai_private_3" {
  type        = string
  default     = "ap-south-1a"
  description = "AZ for additional private subnet in Mumbai"
}

# NEW: AZ for Virginia new private subnet
variable "az_virginia_private_3" {
  type        = string
  default     = "us-east-1c"
  description = "AZ for additional private subnet in Virginia"
}
variable "my_ip_cidr" {
  type        = string
  description = "Your public IP in CIDR format for SSH access to Bastion. Example: 49.37.xx.xx/32"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "key_name_bastion_mumbai" {
  type        = string
  description = "Existing EC2 Key Pair name for Bastion in Mumbai"
}

variable "key_name_private_mumbai" {
  type        = string
  description = "Existing EC2 Key Pair name for Private EC2 in Mumbai"
}

variable "key_name_virginia" {
  type        = string
  description = "Existing EC2 Key Pair name in N. Virginia"
}
