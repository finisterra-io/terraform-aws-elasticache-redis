variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

variable "name" {
  description = "The name of the parameter group"
  type        = string
  default     = ""
}

variable "description" {
  description = "The description of the parameter group"
  type        = string
  default     = ""
}

variable "family" {
  description = "The family of the parameter group"
  type        = string
}

variable "parameters" {
  description = "A list of parameters to set in the parameter group"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
