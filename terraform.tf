variable "resource_group_name" {
  type        = string
  description = "the name of the resource group to create"
}
variable "resource_group_location" {
  type        = string
  description = "the azure region to deploy the resources to"
}

variable "app_service_plan_name" {
  type        = string
  description = "the name of the app service plan to create"
}
variable "app_service_name" {
  type        = string
  description = "the name of the app service to create"
}
variable "sql_server_name" {
  type        = string
  description = "the name of the sql server to create"
}
variable "sql_database_name" {
  type        = string
  description = "the name of the sql database to create"
}

variable "sql_admin_username" {
  type        = string
  description = "the administrator username for the sql server"
}
variable "sql_admin_password" {
  type        = string
  description = "the administrator password for the sql server"
}
variable "firewall_rule_name" {
  type        = string
  description = "the name of the firewall rule to create"
}
variable "repo_url" {
  type        = string
  description = "the url of the github repository to link to the app service"
}
