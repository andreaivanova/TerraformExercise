terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.65.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
  }
}

provider "azurerm" {
  features {

  }
  # Configuration options
  subscription_id = "0c6a0ca9-24ef-45a3-9eb8-b61d0ba52b94"
}
resource "random_integer" "ri" {
  min = 10000
  max = 99999

}
resource "azurerm_resource_group" "arg" {
  # returns a random number between 10000 and 99999 and appends
  #  it to the resource group name to ensure uniqueness
  name = "${var.resource_group_name}${random_integer.ri.result}"

  location = var.resource_group_location
}

resource "azurerm_service_plan" "asp" {
  name                = "${var.app_service_plan_name}${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.arg.name
  location            = azurerm_resource_group.arg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "alwa" {
  name                = "${var.app_service_name}${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.arg.name
  location            = azurerm_service_plan.asp.location
  service_plan_id     = azurerm_service_plan.asp.id

  connection_string {
    name  = "DefaultConnection"
    value = "Data Source=tcp:${azurerm_mssql_server.sqlserver.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.database.name};User ID=${azurerm_mssql_server.sqlserver.administrator_login};Password=${azurerm_mssql_server.sqlserver.administrator_login_password};Trusted_Connection=False; MultipleActiveResultSets=True;"
    type  = "SQLAzure"
  }
  site_config {
    application_stack {
      dotnet_version = "6.0"
    }

    always_on = false
  }
}

resource "azurerm_mssql_server" "sqlserver" {
  name                         = "${var.sql_server_name}${random_integer.ri.result}"
  resource_group_name          = azurerm_resource_group.arg.name
  location                     = azurerm_resource_group.arg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password

  # administrator_login          = "4dm1n157r470r"
  # administrator_login_password = "4-v3ry-53cr37-p455w0rd"
  # minimum_tls_version          = "1.2"

  # azuread_administrator {
  #   login_username = "AzureAD Admin"
  #   object_id      = "00000000-0000-0000-0000-000000000000"
  # }

  # tags = {
  #   environment = "production"
  # }
}

resource "azurerm_mssql_database" "database" {
  name                 = "${var.sql_database_name}${random_integer.ri.result}"
  server_id            = azurerm_mssql_server.sqlserver.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  license_type         = "LicenseIncluded"
  max_size_gb          = 2
  sku_name             = "S0"
  zone_redundant       = false
  geo_backup_enabled   = false
  storage_account_type = "Local"
  # requested_backup_storage_redundancy = "Local"



  # enclave_type = "VBS"

  # tags = {
  #   foo = "bar"
  # }

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_mssql_firewall_rule" "FirewallRule1" {
  name             = var.firewall_rule_name
  server_id        = azurerm_mssql_server.sqlserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_app_service_source_control" "github" {
  app_id                 = azurerm_linux_web_app.alwa.id
  repo_url               = var.repo_url
  branch                 = "main"
  use_manual_integration = true
}


