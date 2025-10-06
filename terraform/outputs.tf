output "cluster_name" {
  value = module.eks.cluster_id
}
output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --name ${module.eks.cluster_id} --region ${var.region}"
}
output "ecr_urls" {
  value = {
    frontend = aws_ecr_repository.frontend.repository_url
    backend  = aws_ecr_repository.backend.repository_url
    mongodb  = aws_ecr_repository.mongodb.repository_url
  }
}

