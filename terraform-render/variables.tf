variable "repo_url" {
  description = "HTTPS URL of the GitHub repository containing the skill-12-exp-Deployment-render-using-docker-Terraform project root."
  type        = string
}

variable "git_branch" {
  description = "Git branch to deploy."
  type        = string
  default     = "main"
}

variable "region" {
  description = "Render region. Keep all services and the database in the same region."
  type        = string
  default     = "singapore"
  validation {
    condition     = contains(["frankfurt", "ohio", "oregon", "singapore", "virginia"], var.region)
    error_message = "Choose a supported Render region: frankfurt, ohio, oregon, singapore, or virginia."
  }
}

variable "web_plan" {
  description = "Free Render web-service plan; free instances sleep when idle and have limited resources."
  type        = string
  default     = "free"
}

variable "postgres_plan" {
  description = "Free Render PostgreSQL plan; the database expires after 30 days."
  type        = string
  default     = "free"
}

variable "jwt_secret" {
  description = "Strong random secret shared by auth and book services. Supply via TF_VAR_jwt_secret, never commit it."
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.jwt_secret) >= 32
    error_message = "jwt_secret must contain at least 32 characters."
  }
}
