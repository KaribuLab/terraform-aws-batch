variable "subnet_ids" {
  type = list(string)
}

variable "common_tags" {
  type = map(any)
}

variable "name" {
  type = string
}

variable "max_vcpus" {
  type = number
}

variable "job_vcpu" {
  type = number
}

variable "job_environment" {
  type    = list(map(string))
  default = []
}

variable "job_memory" {
  type = number
}

variable "job_command" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "job_policy" {
  type = string
}

variable "ecr_repository_url" {
  type = string
}

variable "job_timeout" {
  type        = number
  description = "Tiempo máximo de ejecución de cada intento del job en segundos (mínimo 60). Si es null, el job no tiene timeout."
  default     = null

  validation {
    condition     = var.job_timeout == null || try(var.job_timeout >= 60, false)
    error_message = "job_timeout debe ser null o un número mayor o igual a 60 segundos (mínimo exigido por AWS Batch)."
  }
}
