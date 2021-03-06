variable "azdata_username" {
  description = "Azdata username"
  type        = string
  default     = "azuser"
}

variable "AZDATA_PASSWORD" {
  description = "azdata password is set via an environment variable, export TF_VAR_AZDATA_PASSWORD=<password goes here>"
  type        = string
}

variable "arc_data_namespace" {
  description = "Kubernetes namespace for Azure Arc for Data Services controller"
  type        = string
  default     = "arc-ds-controller"
}

variable "use_load_balancer" {
  description = "Use LoadBalancer services if set to true, other use NodePort"
  default     = true
}

variable "arc_data_connectivity_mode" {
  description = "Mode for data controller connectivity with Azure (direct/indirect)"
  type        = string
  default     = "indirect"
}

variable "arc_data_az_subscription_id" {
  description = "Subscription GUID for where the data controller resource is to be created in Azure"
  type        = string
  default     = "abcdefgh-ijkl-1234-5678-mnopqrstuvwx"
}

variable "arc_data_resource_group" {
  description = "Resource group group where the data controller resource is to be created in Azure"
  type        = string
  default     = "arc-ds-rg"
}

variable "arc_data_az_location" {
  description = "Location where controller resource metadata will be stored in Azure"
  type        = string
  default     = "eastus"
}

variable "arc_data_profile_dir" {
  description = "Directory were Azure Arc enabled Data Services profile is created"
  type        = string
  default     = "ca_arc"
}

variable "arc_data_storage_class" {
  description = "Storage class for data"
  type        = string
  default     = "portworx-sc"
}

variable "arc_logs_storage_class" {
  description = "Storage class for logs"
  type        = string
  default     = "portworx-sc"
}

variable "application_name" {
  default     = "Azure Arc enabled Data Services"
}

variable "password_length" {
  default     = 16
}

variable "password_special" {
  default     = true
}

variable "password_override_special" {
  default     = "_%@" 
}
