variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "fooocus-batch"
}

variable "environment" {
  description = "Entorno (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "ID de la VPC existente (si no se crea una nueva)"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "IDs de las subnets existentes (si no se crean nuevas)"
  type        = list(string)
  default     = []
}

variable "instance_type" {
  description = "Tipo de instancia para la generación de imágenes"
  type        = string
  default     = "g4dn.xlarge"
}

variable "max_vcpus" {
  description = "Número máximo de vCPUs para el entorno de computación"
  type        = number
  default     = 16
}

variable "min_vcpus" {
  description = "Número mínimo de vCPUs para el entorno de computación"
  type        = number
  default     = 0
}

variable "job_timeout_seconds" {
  description = "Tiempo máximo en segundos para un job antes de cancelarlo"
  type        = number
  default     = 1800  # 30 minutos
}

variable "idle_timeout_seconds" {
  description = "Tiempo máximo de inactividad antes de terminar la instancia"
  type        = number
  default     = 300  # 5 minutos
}
