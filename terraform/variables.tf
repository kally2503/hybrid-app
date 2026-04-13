variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  default     = "hybrid-app-cluster"
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes (t3.small to stay cost-effective)"
  default     = "t3.small"
}

variable "node_desired_count" {
  description = "Desired number of worker nodes (keep at 1 to minimize cost)"
  default     = 1
}

variable "node_max_count" {
  description = "Maximum number of worker nodes"
  default     = 2
}
