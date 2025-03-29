#!/bin/bash

# Script de entrada para el contenedor Docker
# Este script ejecuta Fooocus con los parámetros proporcionados

set -e

echo "Iniciando Fooocus con los siguientes parámetros:"
echo "Prompt: $1"
echo "Negative Prompt: $2"
echo "Output Path: $3"

# Ejecutar el punto de entrada de Python
python3 entry_point.py "$1" "$2" "$3"
