# 📦 GyanaSetu(Offline AI Tutor) — Submission Instructions

Thank you for reviewing this project. This submission includes all required components in a structured format. Please follow the instructions below to navigate and run the project.

---

## 🗂 Submission Folder Overview

ai-tutor-submission.zip
├── Instructions/            ← 📄 This file
├── Offline_AI_Tutor.pptx    ← 🎯 Project presentation (10 slides)
├── Code/                    ← 💻 Source code (fine-tuning, inference, setup)
├── Flutter_UI_Scaffold/     ← 📱 Mobile app UI scaffold (Flutter)
├── Demo/                    ← 🎥 Demo video
└── Resources/               ← 📚 Hugging Face links, model/dataset cards, screenshots

---

## 🔧 1. How to Run the Offline Tutor Locally

📄 See: `Code/Instructions.txt`

That file explains:
- How to download the model using `download_assets.py`
- How to run inference via `llama.cpp`
- How to launch the Flask UI
- How to build `llama.cpp` using `setup_llama.sh`

---

## 📽 2. Demo Video

📂 Location: `Demo/demo_video.mp4`

- Shows the model running fully offline using `llama.cpp`
- Demonstrates both REPL and web chat interface

---

## 💻 3. Source Code

📂 Location: `Code/`

Includes:
- `finetune_sloth.py` — Script to fine-tune the model with your educational dataset
- `quantize.sh` — Script to quantize to GGUF using `llama.cpp`
- `download_assets.py` — Pulls model files (GGUF, LoRA, tokenizer) from Hugging Face
- `chat_interface.py` — Flask-based chat interface
- `setup_llama.sh` — Builds and copies `llama.cpp` binaries
- `llama_cpp_bin/` — Includes compiled `main` and `quantize` executables

---

## 📱 4. Flutter Mobile App UI

📂 Location: `Flutter_UI_Scaffold/`

- Basic Flutter chat interface scaffold
- To run:
  flutter pub get
  flutter run

This is currently a UI-only prototype (ready for FFI integration with llama.cpp).

---

## 🔗 5. Resources

📂 Location: `Resources/`

- `huggingface_links.txt` — Links to your model and dataset repos on Hugging Face
- `model_card.md` — Info on the fine-tuned Gemma-3N GGUF model
- `dataset_card.md` — Info on your educational dataset
- `screenshots/` — UI + REPL preview images
- `licenses/` — Licenses for model and dataset

---

## 🧠 Optional: Re-Fine-Tuning or Re-Quantizing

Detailed in:
📄 `Code/Instructions.txt`, Section 9  
Use this if you wish to retrain or re-quantize the model using your dataset.

---

If you face any issues, start from `Code/setup_llama.sh` to rebuild binaries and follow instructions step-by-step from there.

Thank you!
