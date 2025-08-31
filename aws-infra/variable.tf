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

## example terraform.tfvars
dns = {
    base_domain_name = "yourdomain_name.com"
    app_domain_name  = "yourdomain_name.com"
}

bucket_name = "yourdomain_name.com" 
