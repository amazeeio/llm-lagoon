ARG CUDA_IMAGE="12.1.1-devel-ubuntu22.04"
FROM nvidia/cuda:${CUDA_IMAGE}

# Model to use
ENV MODEL=Rijgersberg/GEITje-7B-chat-v2-gguf

# Exact filename of the model
ENV FILENAME=GEITje-7B-chat-v2.gguf

# Exact filename of the model
ENV N_CTX=8096

# Chat format
ENV CHAT_FORMAT=zephyr

# Chat format
ENV CHAT_FORMAT=openchat

# Directory to store the model
ENV DATADIR=/data

# CUDA Docker image architecture
ENV CUDA_DOCKER_ARCH=all

# Tell LLAMA_CUBLAS that we want to use cuBLAS
ENV LLAMA_CUBLAS=1

# Tell LLAMA_CPP that we want to offload layers to the GPU
ENV LLAMA_CPP_ARGS="--n_gpu_layers=32"

# Set environment variable for the host
ENV HOST=0.0.0.0

# Force cmake to run
ENV FORCE_CMAKE=1

# Set cmake args cublas on
ENV CMAKE_ARGS="-DLLAMA_CUBLAS=on"

# Install the package
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y git build-essential \
    python3 python3-pip gcc wget \
    ocl-icd-opencl-dev opencl-headers clinfo \
    libclblast-dev libopenblas-dev \
    && mkdir -p /etc/OpenCL/vendors && echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd \
    && rm -rf /var/lib/apt/lists/*

# Set a working directory for better clarity
WORKDIR /app

COPY ./requirements.txt /app/requirements.txt
COPY ./start-llm.sh /app/start-llm.sh
COPY ./hug_model.py /app/hug_model.py

RUN pip install -r /app/requirements.txt

# Expose a port for the server
EXPOSE 8000

# Run the server start script
CMD ["/app/start-llm.sh"]