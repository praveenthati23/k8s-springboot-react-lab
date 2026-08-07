variable "aws_region" {
  description = "AWS region for all lab resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix used on all resource names/tags"
  type        = string
  default     = "k8s-lab"
}

variable "instance_type" {
  description = "EC2 instance type for both master and worker nodes. t3.small (2 vCPU/2GB) is the minimum kubeadm's control plane will accept."
  type        = string
  default     = "t3.small"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB for each node"
  type        = number
  default     = 10
}

variable "key_name" {
  description = "Name to register the EC2 key pair under in AWS"
  type        = string
  default     = "k8s-lab-key"
}

variable "public_key_path" {
  description = "Path to the local SSH public key to import into AWS"
  type        = string
  default     = "~/.ssh/k8s-lab-key.pub"
}

variable "my_ip_cidr" {
  description = "Your public IP in CIDR form (e.g. 103.45.67.89/32) - used to lock down SSH and the Kubernetes API port to just you"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the lab VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the single public subnet both nodes live in"
  type        = string
  default     = "10.0.1.0/24"
}
