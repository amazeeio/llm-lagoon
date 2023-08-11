ARG CUDA_IMAGE="12.1.1-devel-ubuntu22.04"
FROM nvidia/cuda:${CUDA_IMAGE}

# Install the package
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y git build-essential \
    python3 python3-pip gcc wget \
    ocl-icd-opencl-dev opencl-headers clinfo \
    libclblast-dev libopenblas-dev \
    && mkdir -p /etc/OpenCL/vendors && echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

ENV CUDA_DOCKER_ARCH=all
ENV LLAMA_CUBLAS=1

RUN python3 -m pip install --upgrade pip pytest cmake scikit-build setuptools fastapi uvicorn sse-starlette pydantic-settings requests

RUN CMAKE_ARGS="-DLLAMA_CUBLAS=on" FORCE_CMAKE=1 pip install llama-cpp-python

# Run the server
ENV MODEL=vicuna-13B-v1.5-16K-GGML

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