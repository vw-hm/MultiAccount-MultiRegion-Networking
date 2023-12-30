variable "r1_environment" {
  description = "The Deployment environment"
  default = "dev"
}

variable "r1_vpc_cidr" {
  description = "The CIDR block of the vpc"
  default = "10.0.0.0/16"
}

variable "r1_public_subnets_cidr" {
  type        = list
  description = "The CIDR block for the public subnet"
  default = ["10.0.1.0/24","10.0.2.0/24"]
}

variable "r1_private_subnets_cidr" {
  type        = list
  description = "The CIDR block for the private subnet"
  default = ["10.0.10.0/24","10.0.20.0/24"]
}

variable "r1_availability_zones" {
  type        = list
  description = "The az that the resources will be launched"
  default = ["eu-west-1a", "eu-west-1b"]
}

variable "r1_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"  # Change the default value as needed
}

variable "r1_global_prefix" {
  type    = string
  default = "demo-tgw-r1"
}



variable "r2_environment" {
  description = "The Deployment environment"
  default = "prd"
}

variable "r2_vpc_cidr" {
  description = "The CIDR block of the vpc"
  default = "10.10.0.0/16"
}

variable "r2_public_subnets_cidr" {
  type        = list
  description = "The CIDR block for the public subnet"
  default = ["10.10.1.0/24","10.10.2.0/24"]
}

variable "r2_private_subnets_cidr" {
  type        = list
  description = "The CIDR block for the private subnet"
  default = ["10.10.10.0/24","10.10.20.0/24"]
}

variable "r2_availability_zones" {
  type        = list
  description = "The az that the resources will be launched"
  default = ["eu-central-1a", "eu-central-1b"]
}

variable "r2_region" {
  description = "AWS region"
  type        = string
  default     = "eu-cental-1"  # Change the default value as needed
}

variable "r2_global_prefix" {
  type    = string
  default = "demo-tgw-r2"
}



variable "r3_environment" {
  description = "The Deployment environment"
  default = "rmt"
}

variable "r3_vpc_cidr" {
  description = "The CIDR block of the vpc"
  default = "10.20.0.0/16"
}

variable "r3_public_subnets_cidr" {
  type        = list
  description = "The CIDR block for the public subnet"
  default = ["10.20.1.0/24","10.20.2.0/24"]
}

variable "r3_private_subnets_cidr" {
  type        = list
  description = "The CIDR block for the private subnet"
  default = ["10.20.10.0/24","10.20.20.0/24"]
}

variable "r3_availability_zones" {
  type        = list
  description = "The az that the resources will be launched"
  default = ["eu-west-1a", "eu-west-1b"]
}

variable "r3_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"  # Change the default value as needed
}

variable "r3_global_prefix" {
  type    = string
  default = "demo-tgw-r3"
}

