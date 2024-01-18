ARG UBUNTU_VERSION=22.04

# This needs to generally match the container host's environment.
ARG CUDA_VERSION=11.7.1

# Target the CUDA build image
ARG BASE_CUDA_DEV_CONTAINER=nvidia/cuda:${CUDA_VERSION}-devel-ubuntu${UBUNTU_VERSION}

FROM ${BASE_CUDA_DEV_CONTAINER}

# Model to use
ENV MODEL=Rijgersberg/GEITje-7B-chat-v2-gguf

# Exact filename of the model
ENV FILENAME=GEITje-7B-chat-v2.gguf

# Chat format
ENV CHAT_FORMAT=zephyr

# Chat format
ENV CHAT_FORMAT=openchat

# Directory to store the model
ENV DATADIR=/data

# Unless otherwise specified, we make a fat build.
ARG CUDA_DOCKER_ARCH=all

# Set nvcc architecture
ENV CUDA_DOCKER_ARCH=${CUDA_DOCKER_ARCH}

# Enable cuBLAS
ENV LLAMA_CUBLAS=1

# Tell LLAMA_CPP that we want to offload layers to the GPU
ENV LLAMA_CPP_ARGS="--n_gpu_layers=43"

# Set environment variable for the host
ENV HOST=0.0.0.0

# Install the package
RUN apt-get update && \
    apt-get install -y build-essential python3 python3-pip git

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