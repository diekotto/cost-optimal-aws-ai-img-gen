output "batch_job_queue_arn" {
  description = "ARN de la cola de trabajos de AWS Batch"
  value       = aws_batch_job_queue.main.arn
}

output "batch_job_definition_arn" {
  description = "ARN de la definición de trabajo de AWS Batch"
  value       = aws_batch_job_definition.fooocus.arn
}

output "ecr_repository_url" {
  description = "URL del repositorio ECR"
  value       = aws_ecr_repository.fooocus.repository_url
}

output "job_submission_command" {
  description = "Comando para enviar un trabajo de ejemplo"
  value       = "aws batch submit-job --job-name fooocus-test --job-queue ${aws_batch_job_queue.main.name} --job-definition ${aws_batch_job_definition.fooocus.name}"
}
