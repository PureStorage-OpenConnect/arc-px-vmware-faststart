variable "helm_chart_version" {
  default     = "0.9.5"
}

variable "ip_range_lower_boundary" {
  description = "Lower boundary of the range of IP addresses that can be assigned to the LoadBalancer service"
  type        = string
  default     = "192.168.123.100"
}

variable "ip_range_upper_boundary" {
  description = "Upper boundary of the range of IP addresses that can be assigned to the LoadBalancer service"
  type        = string
  default     = "192.168.123.120"
}
