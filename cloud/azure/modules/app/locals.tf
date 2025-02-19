locals {
  # The hard-coded zero indexes here are necessary to access the fqdn from the record set associated with it
  # because the private_dns_zone_configs and record_sets blocks expose lists, even if we only have one dns zone
  # and record set configured.
  postgres_private_link = azurerm_private_endpoint.endpoint.private_dns_zone_configs[0].record_sets[0].fqdn
  generated_hostname    = "${var.application_name}-${random_pet.server.id}.azurewebsites.net"

  postgres_password_keyvault_id   = "postgres-password"
  app_secret_key_keyvault_id      = "app-secret-key"
  api_secret_salt_key_keyvault_id = "api-secret-salt"
  adfs_secret_keyvault_id         = "adfs-secret"
  aws_secret_access_token         = "aws-secret-access-token"
  aws_access_key_id               = "aws-access-key-id"

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    PORT                                = 9000

    DOCKER_REGISTRY_SERVER_URL = "https://index.docker.io"

    DB_USERNAME    = "${azurerm_postgresql_server.civiform.administrator_login}@${azurerm_postgresql_server.civiform.name}"
    DB_PASSWORD    = data.azurerm_key_vault_secret.postgres_password.value
    DB_JDBC_STRING = "jdbc:postgresql://${local.postgres_private_link}:5432/postgres?ssl=true&sslmode=require"

    STORAGE_SERVICE_NAME = "azure-blob"

    # STAGING_HOSTNAME and BASE_URL are slot settings which are managed outside of Terraform
    # but we need to set an initial value for them here so that the ignore_changes block will work
    STAGING_HOSTNAME = "placeholder"
    BASE_URL         = "placeholder"

    CIVIFORM_TIME_ZONE_ID              = var.civiform_time_zone_id
    WHITELABEL_CIVIC_ENTITY_SHORT_NAME = var.civic_entity_short_name
    WHITELABEL_CIVIC_ENTITY_FULL_NAME  = var.civic_entity_full_name
    WHITELABEL_SMALL_LOGO_URL          = var.civic_entity_small_logo_url
    WHITELABEL_LOGO_WITH_NAME_URL      = var.civic_entity_logo_with_name_url
    FAVICON_URL                        = var.favicon_url
    SUPPORT_EMAIL_ADDRESS              = var.civic_entity_support_email_address

    AZURE_STORAGE_ACCOUNT_NAME      = azurerm_storage_account.files_storage_account.name
    AZURE_STORAGE_ACCOUNT_CONTAINER = azurerm_storage_container.files_container.name

    AWS_SES_SENDER        = var.sender_email_address
    AWS_ACCESS_KEY_ID     = data.azurerm_key_vault_secret.aws_access_key_id.value
    AWS_SECRET_ACCESS_KEY = data.azurerm_key_vault_secret.aws_secret_access_token.value
    AWS_REGION            = var.aws_region

    STAGING_ADMIN_LIST     = var.staging_program_admin_notification_mailing_list
    STAGING_TI_LIST        = var.staging_ti_notification_mailing_list
    STAGING_APPLICANT_LIST = var.staging_applicant_notification_mailing_list

    SECRET_KEY = data.azurerm_key_vault_secret.app_secret_key.value

    AD_GROUPS_ATTRIBUTE_NAME                  = var.ad_groups_attribute_name
    ADFS_SECRET                               = data.azurerm_key_vault_secret.adfs_secret.value
    ADFS_CLIENT_ID                            = data.azurerm_key_vault_secret.adfs_client_id.value
    ADFS_DISCOVERY_URI                        = data.azurerm_key_vault_secret.adfs_discovery_uri.value
    ADFS_GLOBAL_ADMIN_GROUP                   = var.adfs_admin_group
    CIVIFORM_APPLICANT_IDP                    = var.civiform_applicant_idp
    APPLICANT_OIDC_PROVIDER_LOGOUT            = var.applicant_oidc_provider_logout
    APPLICANT_OIDC_OVERRIDE_LOGOUT_URL        = var.applicant_oidc_override_logout_url
    APPLICANT_OIDC_POST_LOGOUT_REDIRECT_PARAM = var.applicant_oidc_post_logout_redirect_param
    APPLICANT_OIDC_LOGOUT_CLIENT_PARAM        = var.applicant_oidc_logout_client_param

    # The values below are all defaulted to null. If SAML authentication is used, the values can be pulled from the
    # saml_keystore module
    LOGIN_RADIUS_METADATA_URI     = var.login_radius_metadata_uri
    LOGIN_RADIUS_API_KEY          = var.login_radius_api_key
    LOGIN_RADIUS_SAML_APP_NAME    = var.login_radius_saml_app_name
    LOGIN_RADIUS_KEYSTORE_NAME    = (var.saml_keystore_filename != null ? "/saml/${var.saml_keystore_filename}" : "")
    LOGIN_RADIUS_KEYSTORE_PASS    = var.saml_keystore_password
    LOGIN_RADIUS_PRIVATE_KEY_PASS = var.saml_private_key_password

    # In HOCON, env variables set to the empty string are
    # kept as such (set to empty string, rather than undefined).
    # This allows for the default to include atallclaims and for
    # azure AD to not include that claim.
    ADFS_ADDITIONAL_SCOPES = ""

    CIVIFORM_API_SECRET_SALT = data.azurerm_key_vault_secret.api_secret_salt_key.value

    CIVIFORM_APPLICATION_STATUS_TRACKING_ENABLED = var.feature_flag_status_tracking_enabled
    CIVIFORM_API_KEYS_BAN_GLOBAL_SUBNET          = var.civiform_api_keys_ban_global_subnet
    CIVIFORM_SERVER_METRICS_ENABLED              = var.civiform_server_metrics_enabled
  }
  adfs_client_id     = "adfs-client-id"
  adfs_discovery_uri = "adfs-discovery-uri"
}
