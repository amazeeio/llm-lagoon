# Model to use
export MODEL=Rijgersberg/GEITje-7B-chat-v2-gguf

# Exact filename of the model
export FILENAME=GEITje-7B-chat-v2.gguf

# Chat format to use
export CHAT_FORMAT=zephyr

# Directory to store the model, we use the default HuggingFace cache directory
export DATADIR=/$HOME/.cache/huggingface/hub

# Tell LLAMA_CUBLAS that we want to use cuBLAS
export LLAMA_CUBLAS=1

# Set environment variable for the host
export HOST=0.0.0.0

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
python3 -B -m llama_cpp.server --model="${DATADIR}/model.bin" --chat_format="${CHAT_FORMAT}" ${LLAMA_CPP_ARGS}