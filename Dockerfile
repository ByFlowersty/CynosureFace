# === Stage 1: Base y Dependencias del Sistema ===
FROM python:3.10-slim as base

# Variables de entorno estándar
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PIP_NO_CACHE_DIR=1

# Instalar dependencias del SO
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# === Stage 2: Dependencias de Python ===
# Usar el directorio de trabajo estándar de Hugging Face Spaces
WORKDIR /code

# Copiar requerimientos e instalar
COPY requirements.txt ./
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# === Stage 3: Copiar Código y Ejecutar ===
# Copiar el código al WORKDIR actual (/code)
COPY . .

# --- VERIFICAR CONTENIDO DE /code DURANTE EL BUILD ---
RUN echo ">>> Listando contenido de /code:" && ls -la /code

# Exponer el puerto
EXPOSE 7860

# Especificar directorio para DeepFace (puede ser /tmp o dentro de /code)
# Usar /tmp es generalmente más seguro para permisos
ENV DEEPFACE_HOME=/tmp/.deepface

# Comando para ejecutar Uvicorn
# Uvicorn buscará main:app en el WORKDIR (/code) por defecto
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "7860"]
