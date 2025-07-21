#!/usr/bin/env bash
#
# setup_llama.sh
# Clones llama.cpp, builds it, and copies the 'main' and 'quantize'
# binaries into ./llama_cpp_bin so your submission zip has everything.

set -e

# 1. Define versions & paths
LLAMA_REPO="https://github.com/ggerganov/llama.cpp.git"
LLAMA_DIR="llama.cpp"
BUILD_DIR="${LLAMA_DIR}/build"
OUTPUT_DIR="./llama_cpp_bin"

# 2. Clone or update llama.cpp
if [ -d "$LLAMA_DIR" ]; then
  echo "Updating existing llama.cpp..."
  (cd "$LLAMA_DIR" && git pull)
else
  echo "Cloning llama.cpp..."
  git clone --recursive "$LLAMA_REPO" "$LLAMA_DIR"
fi

# 3. Build llama.cpp
echo "Building llama.cpp..."
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . --config Release

# 4. Prepare output folder
cd ../../../   # back to Code/ root
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# 5. Copy binaries
echo "Copying binaries to $OUTPUT_DIR..."
cp "${BUILD_DIR}/bin/main"       "${OUTPUT_DIR}/" || cp "${BUILD_DIR}/main"       "${OUTPUT_DIR}/"
cp "${BUILD_DIR}/bin/quantize"   "${OUTPUT_DIR}/" || cp "${BUILD_DIR}/quantize"   "${OUTPUT_DIR}/"

# 6. Make sure they're executable
chmod +x "${OUTPUT_DIR}/main" "${OUTPUT_DIR}/quantize"

echo "Done!"
echo "→ Executables are in $(realpath ${OUTPUT_DIR})"
