FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    python3-pip \
    libgl1-mesa-glx \
    libglib2.0-0 \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio de trabajo
WORKDIR /app

# Clonar Fooocus
RUN git clone https://github.com/lllyasviel/Fooocus.git .

# Instalar dependencias de Python
RUN pip3 install --no-cache-dir -r requirements.txt

# Crear directorio para salida
RUN mkdir -p /output

# Copiar script de entrada
COPY scripts/entrypoint.sh /app/
COPY scripts/entry_point.py /app/

# Hacer ejecutable el script de entrada
RUN chmod +x /app/entrypoint.sh

# Precargar modelos (opcional - hace la imagen más grande pero reduce el tiempo de inicio)
RUN python3 download_models.py

ENTRYPOINT ["/app/entrypoint.sh"]
