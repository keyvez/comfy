#!/bin/bash

# Check if conda is installed
if ! command -v conda &> /dev/null; then
    echo "Conda could not be found. Please install conda first."
    exit 1
fi

ENV_NAME="ComfyUI_env"

# Check if the conda environment already exists
if conda info --envs | grep -q "$ENV_NAME"; then
    echo "Conda environment '$ENV_NAME' already exists."
else
    echo "Creating conda environment '$ENV_NAME'..."
    conda create -y -n "$ENV_NAME" python=3.8
fi

# Activate conda environment
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate "$ENV_NAME"

# Attempt to install packages from the system's Python environment
pkg_list=$(pip freeze | grep -v '^\-e')

if [ -n "$pkg_list" ]; then
    echo "$pkg_list" | xargs -n1 pip install
else
    echo "No packages to install from the system's Python environment."
fi
