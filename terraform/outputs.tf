output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.hybrid_cluster.endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.hybrid_cluster.name
}

output "cost_warning" {
  description = "Cost reminder"
  value       = "EKS costs ~$3/day. Run 'terraform destroy' when done testing!"
}
