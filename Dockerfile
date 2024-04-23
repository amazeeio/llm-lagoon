# Use the image as specified
FROM python:3-slim-bookworm

# Model to use
ENV MODEL=QuantFactory/Meta-Llama-3-8B-Instruct-GGUF

# Exact filename of the model
ENV FILENAME=Meta-Llama-3-8B-Instruct.Q8_0.gguf

# Exact filename of the model
ENV N_CTX=8096

# Chat format
ENV CHAT_FORMAT=llama-3

# Directory to store the model
ENV DATADIR=/data

# Tell LLAMA_CUBLAS that we want to use cuBLAS
ENV LLAMA_CUBLAS=1

# Set environment variable for the host
ENV HOST=0.0.0.0

# Force cmake to run
ENV FORCE_CMAKE=1

# Set cmake args openblas on
ENV CMAKE_ARGS="-DLLAMA_BLAS=ON -DLLAMA_BLAS_VENDOR=OpenBLAS"

# Update and upgrade the existing packages
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    python3 \
    python3-pip \
    ninja-build \
    libopenblas-dev \
    pkg-config \
    build-essential

# Clean up apt cache
RUN rm -rf /var/lib/apt/lists/*

# Set a working directory for better clarity
WORKDIR /app

COPY ./requirements.txt /app/requirements.txt
COPY ./start-llm.sh /app/start-llm.sh
COPY ./hug_model.py /app/hug_model.py

RUN pip install -r requirements.txt

# Expose a port for the server
EXPOSE 8000

# Run the server start script
CMD ["/app/start-llm.sh"]