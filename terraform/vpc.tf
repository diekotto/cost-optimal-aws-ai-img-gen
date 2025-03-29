# Si no se proporciona una VPC existente, crea una nueva
resource "aws_vpc" "batch" {
  count = length(var.vpc_id) > 0 ? 0 : 1
  
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name        = "${var.project_name}-vpc-${var.environment}"
    Environment = var.environment
  }
}

# Crea subnets si no se proporcionan
resource "aws_subnet" "batch" {
  count = length(var.subnet_ids) > 0 ? 0 : 2
  
  vpc_id                  = length(var.vpc_id) > 0 ? var.vpc_id : aws_vpc.batch[0].id
  cidr_block              = cidrsubnet("10.0.0.0/16", 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name        = "${var.project_name}-subnet-${count.index}-${var.environment}"
    Environment = var.environment
  }
}

# Internet Gateway para permitir conexiones salientes
resource "aws_internet_gateway" "batch" {
  count = length(var.vpc_id) > 0 ? 0 : 1
  
  vpc_id = aws_vpc.batch[0].id
  
  tags = {
    Name        = "${var.project_name}-igw-${var.environment}"
    Environment = var.environment
  }
}

# Tabla de rutas para dirigir el tráfico a Internet
resource "aws_route_table" "batch" {
  count = length(var.vpc_id) > 0 ? 0 : 1
  
  vpc_id = aws_vpc.batch[0].id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.batch[0].id
  }
  
  tags = {
    Name        = "${var.project_name}-route-table-${var.environment}"
    Environment = var.environment
  }
}

# Asociación de la tabla de rutas a las subnets
resource "aws_route_table_association" "batch" {
  count = length(var.subnet_ids) > 0 ? 0 : 2
  
  subnet_id      = aws_subnet.batch[count.index].id
  route_table_id = aws_route_table.batch[0].id
}

# Grupo de seguridad para las instancias de AWS Batch
resource "aws_security_group" "batch" {
  name        = "${var.project_name}-batch-sg-${var.environment}"
  description = "Security group for Batch instances"
  vpc_id      = length(var.vpc_id) > 0 ? var.vpc_id : aws_vpc.batch[0].id
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "${var.project_name}-batch-sg-${var.environment}"
    Environment = var.environment
  }
}

# EFS para almacenar las imágenes generadas
resource "aws_efs_file_system" "output" {
  creation_token = "${var.project_name}-efs-${var.environment}"
  
  tags = {
    Name        = "${var.project_name}-efs-${var.environment}"
    Environment = var.environment
  }
}

# Puntos de montaje de EFS en cada subnet
resource "aws_efs_mount_target" "output" {
  count = length(var.subnet_ids) > 0 ? length(var.subnet_ids) : 2
  
  file_system_id = aws_efs_file_system.output.id
  subnet_id      = length(var.subnet_ids) > 0 ? var.subnet_ids[count.index] : aws_subnet.batch[count.index].id
  security_groups = [aws_security_group.efs.id]
}

# Grupo de seguridad para EFS
resource "aws_security_group" "efs" {
  name        = "${var.project_name}-efs-sg-${var.environment}"
  description = "Security group for EFS mount targets"
  vpc_id      = length(var.vpc_id) > 0 ? var.vpc_id : aws_vpc.batch[0].id
  
  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.batch.id]
  }
  
  tags = {
    Name        = "${var.project_name}-efs-sg-${var.environment}"
    Environment = var.environment
  }
}

# Datos de las zonas de disponibilidad
data "aws_availability_zones" "available" {}
