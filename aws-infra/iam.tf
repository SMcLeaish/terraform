resource "aws_iam_role" "tf_admin" {
  name = "tf-admin"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::290726015909:user/sm-setup"
        },
        Condition = {
          StringEquals = {
            "sts:ExternalId": "tf-admin"
          }
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "terraform_admin_policy" {
  name = "terraform-admin-policy"
  role = aws_iam_role.tf_admin.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect: "Allow",
        Action: [
          "s3:*",
        ],
        Resource: [
          "arn:aws:s3:::*"
        ]
      },
      {
        Effect: "Allow",
        Action: [
          "dynamodb:*",
        ],
        Resource: [
          "arn:aws:dynamodb:*:*:table/*"
        ]
      },
      {
        Effect: "Allow",
        Action: [
          "iam:*",
        ],
        Resource: [
          "*"
        ]
      },
      {
        Effect: "Allow",
        Action: [
          "route53:*",
        ],
        Resource: [
          "*"
        ] 
      },
      {
        Effect: "Allow",
        Action: [
          "acm:*",
        ],
        Resource: [
          "*"
        ]
      },
    ]  
  })
}

resource "aws_iam_user" "sm_ssh_user" {
  name = "sm-ssh"
}

resource "aws_iam_user_policy_attachment" "sm_ssh_user_cloudshell_full_access" {
  user = aws_iam_user.sm_ssh_user.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudShellFullAccess"
}

resource "aws_iam_user_policy_attachment" "sm_ssh_user_change_password" {
  user       = aws_iam_user.sm_ssh_user.name
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}
