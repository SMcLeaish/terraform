data "aws_iam_policy_document" "cloudfront" {
  statement {
    sid       = "CloudFrontOAItoS3"
    actions   = ["s3:GetObject"]
    effect    = "Allow"
    resources = ["${module.website.s3_bucket_arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      values   = [module.cdn.cloudfront_distribution_arn]
      variable = "AWS:SourceArn"
    }
  }
}
