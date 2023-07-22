variable "location" {
  default = "ap-south-1"
}

variable "os_name" {
  default = "ami-0f5ee92e2d63afc18"
}

variable "key" {
  default = "demo-03"
}

variable "control_plane_type" {
  default = "t2.medium"
}

variable "worker_instance_type" {
  default = "t2.micro"
}

variable "vpc-cidr" {
  default = "10.0.0.0/16"
}

variable "subnet1-cidr" {
  default = "10.0.1.0/24"
}

variable "subnet-az" {
  default = "ap-south-1a"
}
