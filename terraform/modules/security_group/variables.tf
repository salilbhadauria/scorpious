# vim: ts=4:sw=4:et:ft=hcl

variable "vpc_id" {
  description = "VPC ID"
}

variable "sg_name" {
  description = "Security Group name"
}

variable "sg_description" {
  description = "Security Group description"
  default     = "Security group"
}

variable "tags" {
  description = "Tag maps"
  type        = "map"
  default     = {}
}

variable "ingress_rules_cidr" {
  description = "List of maps containing rules and source as CIDR blocks"
  type        = "list"
  default     = []
}

variable "ingress_rules_sgid" {
  description = "List of maps containing rules and source as Security Group IDs"
  type        = "list"
  default     = []
}

variable "egress_rules_cidr" {
  description = "List of maps containing rules and source as CIDR blocks"
  type        = "list"
  default     = []
}

variable "egress_rules_sgid" {
  description = "List of maps containing rules and source as Security Group IDs"
  type        = "list"
  default     = []
}

