# Use the image as specified
FROM python:3-slim-bullseye
ENV MODEL=vicuna-13B-v1.5-16K-GGML

# Update and upgrade the existing packages 
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    python3 \
    python3-pip \
    ninja-build \
    libopenblas-dev \
    build-essential

RUN python3 -m pip install --upgrade pip pytest cmake scikit-build setuptools fastapi uvicorn sse-starlette pydantic-settings

RUN echo "OpenBLAS install:" && \
    pip install requests && \
    CMAKE_ARGS="-DLLAMA_BLAS=ON -DLLAMA_BLAS_VENDOR=OpenBLAS" pip install llama-cpp-python --verbose;

# Clean up apt cache
RUN rm -rf /var/lib/apt/lists/*

# Set a working directory for better clarity
WORKDIR /app

COPY ./amazee_server.sh /app/amazee_server.sh
COPY ./hug_model.py /app/hug_model.py
COPY ./fix-permissions.sh /app/fix-permissions.sh
RUN chmod +x /app/fix-permissions.sh

RUN mkdir -p /data \
    && /app/fix-permissions.sh /data  \
    && /app/fix-permissions.sh /app

# Make the server start script executable
RUN chmod +x /app/amazee_server.sh

# Set environment variable for the host
ENV HOST=0.0.0.0

# Expose a port for the server
EXPOSE 8000

# Run the server start script
CMD ["/bin/sh", "/app/amazee_server.sh"]