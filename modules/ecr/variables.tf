variable "repository_name" {
  description = "ECR repository name"
  type = string
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type = bool
  default = true
}

variable "image_tag_mutability" {
  type = string
  description = "IMMUTABLE blocks changing existing tags; MUTABLE allows overwrite."
  default = "MUTABLE"
}

variable "force_delete" {
  type = bool
  description = "If true, deleting the repo automatically deletes all images inside."
  default = true
}

variable "repository_policy" {
  type = string
  description = "Repository JSON policy."
  default = null
}