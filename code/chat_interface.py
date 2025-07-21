#!/usr/bin/env python3
"""
A minimal Flask web UI that calls the llama.cpp binary
to serve an offline chat interface.
"""
import os
import subprocess
from flask import Flask, render_template_string, request

# === CONFIGURATION ===
LLAMA_BIN    = "/path/to/llama.cpp/build/bin/main"
MODEL_PATH   = "./gemma34b-Q4_K_M.gguf"
LORA_PATH    = "./lora_adapter.bin"
TOKENIZER    = "./tokenizer.json"
NPREDICT     = "128"
TEMP         = "0.7"
# =====================

app = Flask(__name__)

HTML = """
<!doctype html>
<title>Offline AI Tutor</title>
<h1>Offline AI Tutor</h1>
<form method=post>
  <textarea name=prompt rows=4 cols=60 placeholder="Ask me anything…"></textarea><br>
  <button type=submit>Submit</button>
</form>
{% if response %}
  <h2>Response:</h2>
  <pre>{{ response }}</pre>
{% endif %}
"""

def query_llama(prompt: str) -> str:
    cmd = [
        LLAMA_BIN,
        "--model", MODEL_PATH,
        "--lora", LORA_PATH,
        "--tokenizer", TOKENIZER,
        "--prompt", prompt,
        "--n_predict", NPREDICT,
        "--temp", TEMP
    ]
    try:
        out = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return out.stdout.strip()
    except subprocess.CalledProcessError as e:
        return f"[Error running llama.cpp]\n{e.stderr}"

@app.route("/", methods=["GET", "POST"])
def index():
    response = None
    if request.method == "POST":
        prompt = request.form["prompt"]
        response = query_llama(prompt)
    return render_template_string(HTML, response=response)

if __name__ == "__main__":
    # Launch on http://localhost:5000
    app.run(host="0.0.0.0", port=5000, debug=False)
