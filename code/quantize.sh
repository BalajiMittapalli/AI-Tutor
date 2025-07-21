#!/usr/bin/env bash
#
# quantize.sh
# Wrapper around llama.cpp quantize tool to produce Q4_K_M quantized GGUF.

LLAMA_CPP_BUILD="/path/to/llama.cpp/build/bin"
INPUT_BIN="./outputs/lora_model/pytorch_model.bin"
OUTPUT_GGUF="./gemma34b-Q4_K_M.gguf"
METHOD="q4_k_M"

if [ ! -x "$LLAMA_CPP_BUILD/quantize" ]; then
  echo "ERROR: quantize binary not found or not executable at $LLAMA_CPP_BUILD/quantize"
  exit 1
fi

echo "Quantizing $INPUT_BIN → $OUTPUT_GGUF using $METHOD..."
"$LLAMA_CPP_BUILD/quantize" "$INPUT_BIN" "$OUTPUT_GGUF" "$METHOD"
echo "Done."
