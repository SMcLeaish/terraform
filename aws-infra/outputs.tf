output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}

output "github_actions_terraform_role_arn" {
  value = aws_iam_role.github_actions_terraform.arn
}


