variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

variable "name" {
  description = "The name of the subnet group"
  type        = string
  default     = ""
}

variable "description" {
  description = "The description of the subnet group"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "A list of VPC subnet IDs for the subnet group"
  type        = list(string)
  default     = null
}

variable "subnet_names" {
  description = "A list of VPC subnet names for the subnet group"
  type        = list(string)
  default     = null
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
