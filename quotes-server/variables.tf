# -------------------------------
# VARIABLES
# -------------------------------

variable "key_name" {
  description = "SSH key name"
  type        = string
  default     = "k8s-key-pair"
}

variable "custom_ami_id" {
  description = "Custom AMI ID to use for the instances"
  type        = string
  default     = "ami-0b28948b4f73e8e5c"
}

variable "instance_type" {
  description = "Instance type for the Kubernetes nodes"
  type        = string
  default     = "t3.medium"
}
