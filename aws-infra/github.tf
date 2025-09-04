resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
  tags = {
    Name = "GitHub-Actions-OIDC-Provider"
  }
}

resource "aws_iam_role" "github_actions" {
  name = "github-actions-deploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:sub" = "repo:SMcLeaish/astro-blog:ref:refs/heads/main",
            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "github_actions_s3_policy" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::${local.seanmcleaish_bucket}",         
      "arn:aws:s3:::${local.seanmcleaish_bucket}/*"       
    ]
  }
}

resource "aws_iam_policy" "github_actions_s3_policy" {
  name   = "github-actions-s3-policy"
  policy = data.aws_iam_policy_document.github_actions_s3_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_s3_policy.arn
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}

