variable "subnet_count" {
  description = "Number of subnets to create"
  type        = number  
}
variable "vpc_id" {
  description = "VPC ID to associate the subnets with"
  type        = string    
}
variable "subnet_series" {
  description = "Subnet series for CIDR block calculation"
  type        = number  
  default     = 0
}
variable "availability_zones" {
  description = "List of availability zones to use for subnet creation"
  type        = list(string)  
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}
variable "tags" {
  description = "Tags to apply to the subnets"
  type        = map(string)  
}
variable "type" {
  description = "Type of subnet (public/private)"
  type        = string  
  default     = "private"
  validation {
    condition     = contains(["public", "private"], var.type)
    error_message = "Subnet type must be either 'public' or 'private'."
  }
}

variable "internet_gateway_required" {
  description = "Flag to indicate if an internet gateway is required for the subnet"
  type        = bool
  default     = false  
}
variable "route_table_id" {
  description = "Route table ID to associate with the subnet"
  type        = string
  default     = "" 
}


variable "nat_gateway_required" {
  description = "Flag to indicate if a NAT gateway is required for the subnet"
  type        = bool
  default     = false 
}
variable "nat_subnet_id" {
  description = "Subnet ID for the NAT gateway"
  default     = ""
  validation {
    condition     = var.nat_gateway_required == false || var.nat_subnet_id != ""
    error_message = "NAT subnet ID must be provided if NAT gateway is required."
  }
}