# Model to use
export MODEL=QuantFactory/Meta-Llama-3-8B-Instruct-GGUF

# Exact filename of the model
export FILENAME=Meta-Llama-3-8B-Instruct.Q8_0.gguf

# Chat format to use
export CHAT_FORMAT=llama-3

# Directory to store the model, we use the default HuggingFace cache directory
export DATADIR=/$HOME/.cache/huggingface/hub

# Use Metal llama-cpp backend
export CMAKE_ARGS="-DLLAMA_METAL=on"

# Set environment variable for the host
export HOST=0.0.0.0

# Set the context window size
export N_CTX=8096

# Tell LLAMA_CPP that we want to offload layers to the GPU
export LLAMA_CPP_ARGS="--n_gpu_layers=-1"

# check if data directory exists
if [ ! -d "${DATADIR}" ]; then
    mkdir -p "${DATADIR}"
fi

# create virtual environment
python3 -m venv venv
source venv/bin/activate

# install dependencies
echo "Installing dependencies..."
pip install -r requirements.txt

# download model
echo "Downloading model..."
python hug_model.py --model "${MODEL}" --filename "${FILENAME}" --datadir "${DATADIR}"

# run server
echo "Running server..."
python3 -B -m llama_cpp.server --n_gpu_layers=-1 --n_ctx="${N_CTX}" --model="${DATADIR}/model.bin" --chat_format="${CHAT_FORMAT}" ${LLAMA_CPP_ARGS}