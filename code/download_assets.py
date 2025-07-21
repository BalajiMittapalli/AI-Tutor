#!/usr/bin/env python3
"""
download_assets.py

Downloads your quantized GGUF model, LoRA adapter, and tokenizer
from your Hugging Face repo into the current directory.
"""
from huggingface_hub import hf_hub_download

REPO_ID = "BalajiMittapalli/gemma-3n-finetune-edu"
FILES = [
    "gemma34b-Q4_K_M.gguf",
    "lora_adapter.bin",
    "tokenizer.json"
]

if __name__ == "__main__":
    for fn in FILES:
        print(f"Downloading {fn}...")
        path = hf_hub_download(repo_id=REPO_ID, filename=fn)
        print(f"  → saved to {path}")
    print("All assets downloaded.")
