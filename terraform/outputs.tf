output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.hybrid_cluster.endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.hybrid_cluster.name
}

output "ecr_java_url" {
  description = "ECR URL for Java app"
  value       = aws_ecr_repository.java_app.repository_url
}

output "ecr_python_url" {
  description = "ECR URL for Python app"
  value       = aws_ecr_repository.python_app.repository_url
}

output "ecr_angular_url" {
  description = "ECR URL for Angular app"
  value       = aws_ecr_repository.angular_app.repository_url
}

output "cost_warning" {
  description = "Cost reminder"
  value       = "EKS costs ~$3/day. Run 'terraform destroy' when done testing!"
}
