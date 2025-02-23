FROM keyvez/comfy:latest

RUN pip install hf_transfer

# Set HF_HUB_ENABLE_HF_TRANSFER environment variable
ENV HF_HUB_ENABLE_HF_TRANSFER=1

# Login to Hugging Face using mounted secret
RUN --mount=type=secret,id=HF_TOKEN,required=false \
    if [ -f /run/secrets/HF_TOKEN ]; then \
    export HF_TOKEN=$(cat /run/secrets/HF_TOKEN); \
    fi && \
    huggingface-cli login --token "${HF_TOKEN}"

# Download models from black-forest-labs/FLUX.1-dev
RUN huggingface-cli download black-forest-labs/FLUX.1-dev ae.safetensors --local-dir /opt/comfy/models/vae

RUN huggingface-cli download black-forest-labs/FLUX.1-dev flux1-dev.safetensors --local-dir /opt/comfy/models/diffusion_models

# Download text encoders
RUN huggingface-cli download comfyanonymous/flux_text_encoders clip_l.safetensors --local-dir /opt/comfy/models/clip

RUN huggingface-cli download comfyanonymous/flux_text_encoders t5xxl_fp8_e4m3fn.safetensors --local-dir /opt/comfy/models/clip

RUN huggingface-cli download comfyanonymous/flux_text_encoders t5xxl_fp16.safetensors --local-dir /opt/comfy/models/clip

RUN huggingface-cli download easygoing0114/flan-t5-xxl-fused flan_t5_xxl_fp32.safetensors --local-dir /opt/comfy/models/clip

# Download LoRAs
RUN huggingface-cli download WouterGlorieux/GracePenelopeTargaryenV5 GracePenelopeTargaryenV5.safetensors --local-dir /opt/comfy/models/loras

RUN huggingface-cli download VideoAditor/Flux-Lora-Realism flux_realism_lora.safetensors --local-dir /opt/comfy/models/loras

# make the xlabs directory and download lora
RUN mkdir -p /code/comfy/models/xlabs/loras && \
    huggingface-cli download XLabs-AI/flux-RealismLora lora.safetensors --local-dir /opt/comfy/models/xlabs/loras

CMD [ "/start.sh" ]
