import sys
import os
import json
import time
import uuid
from datetime import datetime
import subprocess

def run_fooocus(prompt, negative_prompt, output_path):
    """
    Ejecuta Fooocus con los parámetros proporcionados
    """
    # Crear un ID único para esta generación
    generation_id = str(uuid.uuid4())
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_dir = f"{output_path}/{timestamp}_{generation_id}"
    
    # Asegurarse de que el directorio de salida exista
    os.makedirs(output_dir, exist_ok=True)
    
    # Guardar los parámetros de la generación
    params = {
        "prompt": prompt,
        "negative_prompt": negative_prompt,
        "generation_id": generation_id,
        "timestamp": timestamp
    }
    
    with open(f"{output_dir}/params.json", "w") as f:
        json.dump(params, f, indent=2)
    
    # Construir el comando para ejecutar Fooocus
    cmd = [
        "python", "launch.py",
        "--listen", "0.0.0.0",
        "--port", "7865",
        "--disable-in-browser",
        "--cli",
        "--prompt", prompt
    ]
    
    if negative_prompt:
        cmd.extend(["--negative-prompt", negative_prompt])
    
    cmd.extend(["--outdir", output_dir])
    
    # Ejecutar Fooocus
    print(f"Ejecutando comando: {' '.join(cmd)}")
    process = subprocess.Popen(cmd)
    process.wait()
    
    return output_dir

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Uso: python entry_point.py <prompt> <negative_prompt> <output_path>")
        sys.exit(1)
    
    prompt = sys.argv[1]
    negative_prompt = sys.argv[2]
    output_path = sys.argv[3]
    
    output_dir = run_fooocus(prompt, negative_prompt, output_path)
    print(f"Imágenes generadas en: {output_dir}")
