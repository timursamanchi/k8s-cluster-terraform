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

variable "master_count" {
  description = "Number of master controller nodes"
  type        = number
  default     = 3 # Example: default 3 masters for HA, override as needed
}
variable "worker_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
}

variable "worker_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 5
}

variable "worker_desired_capacity" {
  description = "Desired initial number of worker nodes"
  type        = number
  default     = 2
}

