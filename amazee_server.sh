#!/bin/sh

# For mlock support
ulimit -l unlimited
echo "Model: ${MODEL}"

python3 hug_model.py -s ${MODEL} -f "q5_1"
python3 -B -m llama_cpp.server --model /app/model.bin --n_gpu_layers=43