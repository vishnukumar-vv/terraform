variable "bucket_name" {
  description = "Globally unique S3 bucket name."
  type        = string
}

variable "object_key" {
  description = "S3 object key for the uploaded static file."
  type        = string
}

variable "file_path" {
  description = "Local path to the static file to upload."
  type        = string
}

variable "content_type" {
  description = "Content type for the uploaded file."
  type        = string
  default     = "text/plain"
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow Terraform to delete non-empty bucket during destroy."
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
  default     = {}
}
