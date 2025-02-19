variable "aws_region" {
  type        = string
  description = "Region where the AWS servers will live"
  default     = "us-east-1"
}

variable "civiform_image_repo" {
  type        = string
  description = "Dockerhub repository with Civiform images"
  default     = "civiform/civiform"
}

variable "image_tag" {
  type        = string
  description = "Image tag of the Civiform docker image to deploy"
  default     = "prod"
}

variable "scraper_image" {
  type        = string
  description = "Fully qualified image tag for the metrics scraper"
  default     = "docker.io/civiform/aws-metrics-scraper:latest"
}

variable "civiform_time_zone_id" {
  type        = string
  description = "Time zone for Civiform server to use when displaying dates."
  default     = "America/Los_Angeles"
}

variable "civic_entity_short_name" {
  type        = string
  description = "Short name for civic entity (example: Rochester, Seattle)."
  default     = "Dev Civiform"
}

variable "civic_entity_full_name" {
  type        = string
  description = "Full name for civic entity (example: City of Rochester, City of Seattle)."
  default     = "City of Dev Civiform"
}

variable "civic_entity_support_email_address" {
  type        = string
  description = "Email address where applicants can contact civic entity for support with Civiform."
  default     = "azizoval@google.com"
}

variable "civic_entity_logo_with_name_url" {
  type        = string
  description = "Logo with name used on the applicant-facing program index page"
  default     = "https://raw.githubusercontent.com/civiform/staging-azure-deploy/main/logos/civiform-staging-long.png"
}

variable "civic_entity_small_logo_url" {
  type        = string
  description = "Logo with name used on the applicant-facing program index page"
  default     = "https://raw.githubusercontent.com/civiform/staging-azure-deploy/main/logos/civiform-staging.png"
}

variable "favicon_url" {
  type        = string
  description = "Browser Favicon (16x16 or 32x32 pixels, .ico, .png, or .gif) used on all pages"
  default     = "https://civiform.us/favicon.png"
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC"
  default     = "civiform-vpc"
}

variable "vpc_cidr" {
  type        = string
  description = "Cidr for VPC"
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of the private subnets for the VPC"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "database_subnets" {
  type        = list(string)
  description = "List of the database subnets for the VPC"
  default     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}

variable "public_subnets" {
  type        = list(string)
  description = "List of the public subnets for the VPC"
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "postgress_name" {
  type        = string
  description = "Name for Postress DB"
  default     = "civiform"
}

variable "postgres_instance_class" {
  type        = string
  description = "The instance class for postgres server"
  default     = "db.t3.micro"
}

variable "postgres_storage_gb" {
  type        = number
  description = "The gb of storage for postgres instance"
  default     = 5
}

variable "postgres_backup_retention_days" {
  type        = number
  description = "Number of days to retain postgres backup"
  default     = 7
}

variable "staging_program_admin_notification_mailing_list" {
  type        = string
  description = "Admin notification mailing list for staging"
  default     = null
}

variable "staging_ti_notification_mailing_list" {
  type        = string
  description = "intermediary notification mailing list for staging"
  default     = null
}

variable "sender_email_address" {
  type        = string
  description = "Email address that emails will be sent from"
  default     = null
}

variable "staging_applicant_notification_mailing_list" {
  type        = string
  description = "Applicant notification mailing list for staging"
  default     = null
}

variable "app_prefix" {
  type        = string
  description = "A prefix to add to values so we can have multiple deploys in the same aws account"
  default     = null
}

variable "applicant_oidc_provider_name" {
  type        = string
  description = "Applicant OIDC login provider name"
  default     = null
}

variable "applicant_oidc_response_mode" {
  type        = string
  description = "Applicant OIDC login response mode"
  default     = null
}

variable "applicant_oidc_response_type" {
  type        = string
  description = "Applicant OIDC login response type"
  default     = null
}

variable "applicant_oidc_additional_scopes" {
  type        = string
  description = "Applicant OIDC login additional scopes to request"
  default     = null
}

variable "applicant_oidc_locale_attribute" {
  type        = string
  description = "Applicant OIDC login user locale returned in token"
  default     = null
}

variable "applicant_oidc_email_attribute" {
  type        = string
  description = "Applicant OIDC login user email returned in token"
  default     = null
}

variable "applicant_oidc_first_name_attribute" {
  type        = string
  description = "Applicant OIDC login first name (or display name) returned in token"
  default     = null
}

variable "applicant_oidc_middle_name_attribute" {
  type        = string
  description = "Applicant OIDC login middle name (if not using display name) returned in token"
  default     = null
}

variable "applicant_oidc_last_name_attribute" {
  type        = string
  description = "Applicant OIDC login last name (if not using display name) returned in token"
  default     = null
}

variable "civiform_applicant_idp" {
  type        = string
  description = "Applicant IDP"
  default     = null
}

variable "applicant_oidc_provider_logout" {
  type        = bool
  description = "If the applicant OIDC logout should also perform a central logout from the auth provider"
  default     = true
}

variable "applicant_oidc_override_logout_url" {
  type        = string
  description = "The URL to use for the OIDC logout endpoint (when applicant_oidc_provider_logout is true).  If not set, uses the `end_session_endpoint` value from the discovery metadata."
  default     = null
}

variable "applicant_oidc_post_logout_redirect_param" {
  type        = string
  description = "What query parameter to use for sending the redirect uri to the central OIDC provider for logout (when applicant_oidc_provider_logout is true). Defaults to post_logout_redirect_uri"
  default     = "post_logout_redirect_uri"
}

variable "applicant_oidc_logout_client_param" {
  type        = string
  description = "What query parameter to use for sending the client id to the central OIDC provider for logout (when applicant_oidc_provider_logout is true).  If left blank, doesn't send the client id."
  default     = null
}

variable "applicant_oidc_discovery_uri" {
  type        = string
  description = "Discovery URI"
  default     = null
}

variable "adfs_discovery_uri" {
  type        = string
  description = "ADFS Discovery URI"
  default     = null
}

variable "adfs_additional_scopes" {
  type        = string
  description = "Additional scopes requested during ADFS authentication flow. In Azure AD should be set to empty"
  default     = "allatclaims"
}

variable "ad_groups_attribute_name" {
  type        = string
  description = "Key of authentication id_token map that contains list of groups that user belongs to."
  default     = "group"
}

variable "adfs_admin_group" {
  type        = string
  description = "Name a group in ADFS or group id in Azure AD that user must belong to to be considered CiviForm admin"
  default     = null
}

variable "custom_hostname" {
  type        = string
  description = "The custom hostname this app is deployed on"
  default     = "staging-aws.civiform.dev"
}

variable "staging_hostname" {
  type        = string
  description = "If provided will enable DEMO mode on this hostname"
  default     = "staging-aws.civiform.dev"
}

variable "base_url" {
  type        = string
  description = "Base url for the app, only need to set if you don't have a custom hostname setup"
  default     = ""
}

variable "port" {
  type        = string
  description = "Port the app is running on"
  default     = "9000"
}

variable "civiform_mode" {
  type        = string
  description = "The civiform environment mode (test/dev/staging/prod)"
}

variable "ssl_certificate_arn" {
  type        = string
  description = "ARN of the certificate that will be used to handle SSL traffic. Certificate should be validated."
}

variable "fargate_desired_task_count" {
  type        = number
  description = "Number of Civiform server tasks to run. Can be set to 0 to shutdown server."
}

variable "feature_flag_status_tracking_enabled" {
  type        = bool
  description = "When set to true enable Status Tracking."
  default     = false
}

variable "civiform_api_keys_ban_global_subnet" {
  type        = bool
  description = "Whether to allow 0.0.0.0/0 subnet for API key access."
  default     = true
}

variable "civiform_server_metrics_enabled" {
  type        = bool
  description = "Whether to enable exporting server metrics on the /metrics route."
  default     = false
}

variable "allow_civiform_admin_access_programs" {
  type        = bool
  description = "Whether CiviForm admins can view program applications, similar to Program Admins."
  default     = false
}

variable "pgadmin_cidr_allowlist" {
  type        = list(string)
  description = "List of IPv4 cidr blocks that are allowed access to pgadmin"
  default     = []
}
