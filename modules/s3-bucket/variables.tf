# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# This module has no environment variables

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------

variable "bucket_name" {
  description = "The name of the bucket"
  type        = string
  nullable    = false
  # default     = ""

  validation {
    condition     = length(var.bucket_name) >= 3
    error_message = "The name of the bucket must not be empty"
  }
  validation {
    condition     = length(var.bucket_name) < 63
    error_message = "The name of the bucket must not exceed 63 characters"
  }
  validation {
    condition     = var.bucket_name == lower(var.bucket_name)
    error_message = "The name of the bucket must be in lowercase"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have defaults and may be overridden
# ---------------------------------------------------------------------------------------------------------------------

# --- S3 Bucket ---

variable "enable_force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error"
  type        = bool
  nullable    = false
  default     = false
}

variable "enable_object_lock" {
  description = "A boolean that indicates whether this bucket should have Object Lock enabled"
  type        = bool
  nullable    = false
  default     = false
}

variable "tags" {
  description = "A mapping of tags to assign to the bucket"
  type        = map(any)
  default     = {}
}

# --- Versioning ---

variable "enable_versioning_mfa_delete" {
  description = ""
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.enable_versioning_mfa_delete == null || can(regex("Enabled|Disabled", var.enable_versioning_mfa_delete, ""))
    error_message = "The versioning MFA delete must be either Enabled or Disabled"
  }
}

variable "versioning_mfa" {
  description = ""
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = (var.versioning_mfa == null && var.enable_versioning_mfa_delete == null) && var.enable_versioning_mfa_delete == "Enabled" ? can(length(var.versioning_mfa) > 0) : true
    error_message = "The MFA must be specified when the MFA delete is enabled"
  }
}

# --- Server Side Encryption ---

variable "sse_algorithm" {
  description = ""
  type        = string
  nullable    = false
  default     = "AES256"

  validation {
    condition     = var.sse_algorithm == null || can(regex("AES256|aws:kms|aws:kms:dsse", var.sse_algorithm))
    error_message = "The server side encryption algorithm must be either AES256, aws:kms or aws:kms:dsse"
  }
}

variable "enable_sse_bucket_key" {
  description = ""
  type        = bool
  nullable    = true
  default     = false
}

variable "sse_kms_master_key_id" {
  description = ""
  type        = string
  nullable    = true
  default     = null

  validation {
    condition = (
      (var.sse_algorithm != "aws:kms" && var.sse_kms_master_key_id == null)
      || (can(regex("aws:kms", var.sse_algorithm)) && var.sse_kms_master_key_id != null && can(length(var.sse_kms_master_key_id) > 0))
    )
    error_message = "The KMS master key ID must be specified when the server side encryption algorithm is aws:kms"
  }
}

# --- Inteligent Tiering ---

variable "enable_inteligent_tiering" {
  description = ""
  type        = string
  nullable    = false
  default     = "Enabled"

  validation {
    condition     = var.enable_inteligent_tiering == null || can(regex("Enabled|Disabled", var.enable_inteligent_tiering))
    error_message = "The intelligent tiering status must be either Enabled or Disabled"
  }
}

variable "tiering" {
  description = ""
  type        = map(any)
  nullable    = false
  default = {
    ARCHIVE_ACCESS = {
      days = 125
    }
    DEEP_ARCHIVE_ACCESS = {
      days = 180
    }
  }
}

# --- Logging ---

variable "logging_target_bucket" {
  description = ""
  type        = string
  nullable    = true
  default     = null
}

variable "logging_target_prefix" {
  description = ""
  type        = string
  nullable    = true
  default     = null
}
