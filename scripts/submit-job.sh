#!/bin/bash

# Envía un trabajo a AWS Batch
# Uso: ./submit_job.sh <job_queue> <job_definition> <prompt> <output_path>

set -e

JOB_QUEUE=$1
JOB_DEFINITION=$2
PROMPT=$3
OUTPUT_PATH=$4
NEGATIVE_PROMPT=${5:-""}

if [ -z "$JOB_QUEUE" ] || [ -z "$JOB_DEFINITION" ] || [ -z "$PROMPT" ] || [ -z "$OUTPUT_PATH" ]; then
  echo "Uso: ./submit_job.sh <job_queue> <job_definition> <prompt> <output_path> [negative_prompt]"
  exit 1
fi

# Crear un nombre único para el trabajo
JOB_NAME="fooocus-job-$(date +%Y%m%d%H%M%S)"

# Enviar el trabajo a AWS Batch
aws batch submit-job \
  --job-name $JOB_NAME \
  --job-queue $JOB_QUEUE \
  --job-definition $JOB_DEFINITION \
  --parameters "prompt=$PROMPT,negative_prompt=$NEGATIVE_PROMPT,output_path=$OUTPUT_PATH"

echo "Trabajo $JOB_NAME enviado correctamente"
