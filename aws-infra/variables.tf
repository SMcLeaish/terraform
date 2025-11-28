variable "region" {
  type    = string
  default = "us-east-1"
}
variable "aws_s3_page" {
  type = map(object({
    domain_name = string
    bucket_name = string
  }))
}

variable "github_repositories" {
  description = "List of GitHub repositories to grant access to"
  type = list(object({
    org    = string
    repo   = string
    branch = optional(string, "*")
  }))
  default = [
    {
      org    = "SMcLeaish"
      repo   = "astro-blog"
      branch = "main"
    }
  ]
}
