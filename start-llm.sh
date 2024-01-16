#!/bin/sh

# For mlock support
ulimit -l unlimited
echo "Model: ${MODEL}, FILENAME: ${FILENAME}, CHAT_FORMAT: ${CHAT_FORMAT}, LLAMA_CPP_ARGS: ${LLAMA_CPP_ARGS}, DATADIR: ${DATADIR}"

# Download model
echo "Downloading model..."
python hug_model.py --model "${MODEL}" --filename "${FILENAME}" --datadir "${DATADIR}"

# Run server
echo "Running server..."
python3 -B -m llama_cpp.server --model="${DATADIR}/model.bin" --chat_format="${CHAT_FORMAT}" ${LLAMA_CPP_ARGS}