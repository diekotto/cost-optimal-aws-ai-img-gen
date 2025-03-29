# Entorno de computación para GPU
resource "aws_batch_compute_environment" "gpu" {
  compute_environment_name = "${var.project_name}-gpu-env-${var.environment}"

  compute_resources {
    type           = "EC2"
    allocation_strategy = "BEST_FIT_PROGRESSIVE"
    
    max_vcpus      = var.max_vcpus
    min_vcpus      = var.min_vcpus
    
    instance_type = [
      var.instance_type
    ]
    
    subnets = length(var.subnet_ids) > 0 ? var.subnet_ids : aws_subnet.batch[*].id
    
    security_group_ids = [
      aws_security_group.batch.id
    ]
    
    instance_role = aws_iam_instance_profile.batch.arn
  }

  service_role = aws_iam_role.batch_service_role.arn
  type         = "MANAGED"
  
  depends_on = [
    aws_iam_role_policy_attachment.batch_service_role
  ]
}

# Cola de trabajos principal
resource "aws_batch_job_queue" "main" {
  name                 = "${var.project_name}-queue-${var.environment}"
  state                = "ENABLED"
  priority             = 1
  compute_environments = [
    aws_batch_compute_environment.gpu.arn
  ]
}

# Definición de trabajo para Fooocus
resource "aws_batch_job_definition" "fooocus" {
  name = "${var.project_name}-job-def-${var.environment}"
  type = "container"
  
  timeout {
    attempt_duration_seconds = var.job_timeout_seconds
  }
  
  container_properties = jsonencode({
    image = "${aws_ecr_repository.fooocus.repository_url}:latest",
    resourceRequirements = [
      {
        type  = "VCPU",
        value = "4"
      },
      {
        type  = "MEMORY",
        value = "16384"
      },
      {
        type  = "GPU",
        value = "1"
      }
    ],
    command = ["python", "entry_point.py", "Ref::prompt", "Ref::negative_prompt", "Ref::output_path"],
    environment = [
      {
        name  = "NVIDIA_VISIBLE_DEVICES",
        value = "all"
      },
      {
        name  = "NVIDIA_DRIVER_CAPABILITIES",
        value = "all"
      }
    ],
    jobRoleArn = aws_iam_role.batch_job_role.arn,
    executionRoleArn = aws_iam_role.batch_execution_role.arn,
    volumes = [
      {
        name = "output",
        efsVolumeConfiguration = {
          fileSystemId = aws_efs_file_system.output.id,
          rootDirectory = "/"
        }
      }
    ],
    mountPoints = [
      {
        containerPath = "/output",
        sourceVolume = "output",
        readOnly = false
      }
    ],
    ulimits = [
      {
        hardLimit = 1024000,
        softLimit = 1024000,
        name = "nofile"
      }
    ]
  })
}
