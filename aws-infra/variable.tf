variable "dns" {
  description = "DNS configuration"
  type = object({
    base_domain_name = string
    app_domain_name  = string
  })
}

variable "bucket_name" {
  type        = string
  default     = ""
  description = "Bucket name"
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
      org    = "smcleaish"
      repo   = "astro-blog"
      branch = "main"
    }
  ]
}
