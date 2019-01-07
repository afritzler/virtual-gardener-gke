variable "SERVICEACCOUNT" {
  description = "ServiceAccount"
  type        = "string"
}
variable "PROJECT" {
  type = "string"
}
variable "HOSTED_ZONE_ID" {
  type = "string"
}

variable "DNS_NAME" {
  type = "string"
}

variable "RECORD_TYPE" {
  type = "string"
}

variable "RECORD_VALUE" {
  type = "string"
}