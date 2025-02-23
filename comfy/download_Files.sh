#!/bin/bash

# Install hf_transfer
pip install -q hf_transfer

# Enable HF transfer for faster downloads
export HF_HUB_ENABLE_HF_TRANSFER=1

# Check for token in /run/secrets first
if [ -f "/run/secrets/HF_TOKEN" ]; then
    export HF_TOKEN=$(cat /run/secrets/HF_TOKEN)
fi

if [[ -z "${HF_TOKEN}" ]] || [[ "${HF_TOKEN}" == "enter_your_huggingface_token_here" ]]
then
    echo "HF_TOKEN is not set, can not download flux because it is a gated repository."
else
    echo "HF_TOKEN is set, checking files..."

    if [[ ! -e "/opt/comfy/models/vae/ae.safetensors" ]]
    then
        echo "Downloading ae.safetensors..."
        huggingface-cli download --token ${HF_TOKEN} black-forest-labs/FLUX.1-dev ae.safetensors --local-dir "/opt/comfy/models/vae" --local-dir-use-symlinks False
        mv "/opt/comfy/models/vae/ae.safetensors" "/opt/comfy/models/vae/ae.safetensors"
    else
        echo "ae.safetensors already exists, skipping download."
    fi

    if [[ ! -e "/opt/comfy/models/diffusion_models/flux1-dev.safetensors" ]]
    then
        echo "Downloading flux1-dev.safetensors..."
        huggingface-cli download --token ${HF_TOKEN} black-forest-labs/FLUX.1-dev flux1-dev.safetensors --local-dir "/opt/comfy/models/diffusion_models" --local-dir-use-symlinks False
        mv "/opt/comfy/models/diffusion_models/flux1-dev.safetensors" "/opt/comfy/models/diffusion_models/flux1-dev.safetensors"
    else
        echo "flux1-dev.safetensors already exists, skipping download."
    fi

    if [[ ! -e "/opt/comfy/models/clip/clip_l.safetensors" ]]
    then
        echo "Downloading clip_l.safetensors..."
        huggingface-cli download --token ${HF_TOKEN} comfyanonymous/flux_text_encoders clip_l.safetensors --local-dir "/opt/comfy/models/clip" --local-dir-use-symlinks False
    else
        echo "clip_l.safetensors already exists, skipping download."
    fi

    if [[ ! -e "/opt/comfy/models/clip/t5xxl_fp8_e4m3fn.safetensors" ]]
    then
        echo "Downloading t5xxl_fp8_e4m3fn.safetensors..."
        huggingface-cli download --token ${HF_TOKEN} comfyanonymous/flux_text_encoders t5xxl_fp8_e4m3fn.safetensors --local-dir "/opt/comfy/models/clip" --local-dir-use-symlinks False
    else
        echo "t5xxl_fp8_e4m3fn.safetensors already exists, skipping download."
    fi

    if [[ ! -e "/opt/comfy/models/xlabs/loras/Xlabs-AI_flux-RealismLora.safetensors" ]]
    then
        echo "Downloading Xlabs-AI_flux-RealismLora.safetensors..."
        huggingface-cli download --token ${HF_TOKEN} XLabs-AI/flux-RealismLora lora.safetensors --local-dir "/opt/comfy/models/xlabs/loras" --local-dir-use-symlinks False
        mv "/opt/comfy/models/xlabs/loras/lora.safetensors" "/opt/comfy/models/xlabs/loras/Xlabs-AI_flux-RealismLora.safetensors"
    else
        echo "Xlabs-AI_flux-RealismLora.safetensors already exists, skipping download."
    fi
fi

# Define the download function
download_file() {
    local dir=$1
    local file=$2
    local repo=$(echo $3 | cut -d'/' -f4,5 | cut -d'/' -f1)
    local filename=$(echo $3 | rev | cut -d'/' -f1 | rev | cut -d'?' -f1)

    mkdir -p $dir
    if [ -f "$dir/$file" ]; then
        echo "File $dir/$file already exists, skipping download."
    else
        huggingface-cli download --local-dir "$dir" --local-dir-use-symlinks False "$repo" "$filename"
        if [ "$filename" != "$file" ]; then
            mv "$dir/$filename" "$dir/$file"
        fi
    fi
}

# Download files
download_file "/opt/comfy/models/loras" "GracePenelopeTargaryenV5.safetensors" "https://huggingface.co/WouterGlorieux/GracePenelopeTargaryenV5/resolve/main/GracePenelopeTargaryenV5.safetensors?download=true"
download_file "/opt/comfy/models/loras" "VideoAditor_flux_realism_lora.safetensors" "https://huggingface.co/VideoAditor/Flux-Lora-Realism/resolve/main/flux_realism_lora.safetensors?download=true"
