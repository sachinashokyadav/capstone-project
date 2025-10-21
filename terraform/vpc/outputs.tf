# Outputs related to AWS Load Balancer Controller
output "alb_controller_role_arn" {
  description = "IAM Role ARN for AWS Load Balancer Controller"
  value       = aws_iam_role.alb_controller_role.arn
}

output "alb_controller_policy_arn" {
  description = "IAM Policy ARN for AWS Load Balancer Controller"
  value       = aws_iam_policy.alb_controller_policy.arn
}
