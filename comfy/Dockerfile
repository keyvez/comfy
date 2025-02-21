ARG CUDA_VERSION="12.6.3"
ARG CUDNN_VERSION=""
ARG UBUNTU_VERSION="24.04"
ARG DOCKER_FROM=nvidia/cuda:$CUDA_VERSION-cudnn$CUDNN_VERSION-devel-ubuntu$UBUNTU_VERSION

# Base NVidia CUDA Ubuntu image
FROM $DOCKER_FROM AS base

# Install Python plus openssh, which is our minimum set of required packages.
RUN apt-get update -y && \
    apt-get install -y wget bzip2 && \
    apt-get install -y --no-install-recommends openssh-server openssh-client git git-lfs unzip curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"; \
    else \
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh"; \
    fi && \
    wget $MINICONDA_URL -O miniconda.sh && \
    bash miniconda.sh -b -p /usr/local/miniconda3 && \
    rm miniconda.sh

ENV PATH="/usr/local/miniconda3/bin:/usr/local/cuda/bin:${PATH}"
ENV CONDA_PKGS_DIRS="/opt/conda/pkgs"

# Configure conda to use the cache directory
RUN mkdir -p /opt/conda/pkgs && \
    conda config --add pkgs_dirs /opt/conda/pkgs && \
    conda config --set use_index_cache True && \
    conda config --set channel_priority strict

# Create and activate conda environment
RUN conda create -n comfy python=3.12 pip -y && \
    echo "conda activate comfy" >> ~/.bashrc

SHELL ["conda", "run", "--no-capture-output", "-n", "comfy", "/bin/bash", "--login", "-c"]

# Install nginx
RUN apt-get update && \
    apt-get install -y nginx

# Copy the 'default' configuration file to the appropriate location
COPY default /etc/nginx/sites-available/default

# Install pytorch
ARG PYTORCH="2.6.0"
ARG CUDA="126"
RUN pip install --no-cache-dir torch==$PYTORCH torchvision torchaudio --index-url https://download.pytorch.org/whl/cu$CUDA

COPY --chmod=755 start-ssh-only.sh /start.sh
COPY --chmod=755 start-original.sh /start-original.sh
COPY --chmod=755 comfyui-on-workspace.sh /comfyui-on-workspace.sh
COPY --chmod=755 check_files.sh /check_files.sh

# Install ComfyCLI dependencies
RUN pip install --no-cache-dir comfy-cli

# Install ComfyUI
RUN comfy --workspace=/workspace/comfy install

# ComfyUI-Custom-Scripts
RUN comfy node registry-install comfyui-custom-scripts

# Create pysssss-workflows folder
RUN mkdir pysssss-workflows
RUN mkdir pysssss-workflows

COPY --chmod=644 workflows/ /ComfyUI/pysssss-workflows/
COPY --chmod=644 comfy.settings.json /ComfyUI/user/default/comfy.settings.json
COPY --chmod=644 character_sheet_example.png /ComfyUI/input/character_sheet_example.png
COPY --chmod=644 example_photo.png /ComfyUI/input/example_photo.png
COPY --chmod=644 example_photo_small.png /ComfyUI/input/example_photo_small.png
COPY --chmod=644 example_pose.png /ComfyUI/input/example_pose.png
COPY --chmod=644 example2.png /ComfyUI/input/example2.png

WORKDIR /workspace

EXPOSE 8188

# Download and move flux_dev_example.png
RUN wget "https://github.com/comfyanonymous/ComfyUI_examples/blob/master/flux/flux_dev_example.png" -P /ComfyUI

# Install Xlabs-AI/flux-RealismLora
RUN apt-get install -y libgl1-mesa-glx libglib2.0-0
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/XLabs-AI/x-flux-comfyui.git && \
    cd x-flux-comfyui && \
    python setup.py

# This is a hacky way to change the default workflow on startup, but it works
COPY --chmod=644 defaultGraph.json /defaultGraph.json
COPY --chmod=755 replaceDefaultGraph.py /replaceDefaultGraph.py
# Run the Python script
RUN python /replaceDefaultGraph.py

# Add some additional custom nodes
# LDSR Upscale
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/flowtyone/ComfyUI-Flowty-LDSR.git && \
    cd ComfyUI-Flowty-LDSR && \
    pip install -r requirements.txt

# Add download scripts for additional models
COPY --chmod=755 download_Controlnet.sh /download_Controlnet.sh
COPY --chmod=755 download_fp16.sh /download_fp16.sh
COPY --chmod=755 download_LDSR.sh /download_LDSR.sh
COPY --chmod=755 download_SUPIR.sh /download_SUPIR.sh
COPY --chmod=755 download_Florence-2.sh /download_Florence-2.sh
COPY --chmod=755 download_Upscalers.sh /download_Upscalers.sh
COPY --chmod=755 download_Outpainting.sh /download_Outpainting.sh
COPY --chmod=755 download_Workflows.sh /download_Workflows.sh
COPY --chmod=755 update_Workflows.sh /update_Workflows.sh
COPY --chmod=755 download_ALL.sh /download_ALL.sh
COPY --chmod=755 make_conda_env.sh /make_conda_env.sh
COPY --chmod=755 download_Files.sh /download_Files.sh
COPY --chmod=755 disable_mixlab.sh /disable_mixlab.sh

# SUPIR Upscale (https://registry.comfy.org/nodes/comfyui-supir)
RUN comfy node registry-install comfyui-supir

# KJNodes (https://registry.comfy.org/nodes/comfyui-kjnodes)
RUN comfy node registry-install comfyui-kjnodes

# rgthree (https://registry.comfy.org/nodes/rgthree-comfy)
RUN comfy node registry-install rgthree-comfy

# JPS-Nodes
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/JPS-GER/ComfyUI_JPS-Nodes.git

# Comfyrol Studio
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git

# comfy-plasma
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/Jordach/comfy-plasma.git

# ComfyUI-VideoHelperSuite (https://registry.comfy.org/nodes/comfyui-videohelpersuite)
RUN comfy node registry-install comfyui-videohelpersuite

# ComfyUI-AdvancedLivePortrait (https://registry.comfy.org/nodes/comfyui-advancedliveportrait)
RUN comfy node registry-install comfyui-advancedliveportrait

# ComfyUI-Impact-Subpack (https://registry.comfy.org/nodes/comfyui-impact-subpack)
RUN comfy node registry-install comfyui-impact-subpack

# ComfyUI-Impact-controlnet_aux
RUN comfy node registry-install comfyui-controlnet-aux
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/Fannovel16/comfyui_controlnet_aux.git && \
    cd comfyui_controlnet_aux && \
    pip install -r requirements.txt
# ComfyUI-UltimateSDUpscale (https://registry.comfy.org/nodes/comfyui-ultimatesdupscale)
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/ssitu/ComfyUI_UltimateSDUpscale --recursive

# ComfyUI-Easy-Use (https://registry.comfy.org/nodes/comfyui-easy-use)
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/yolain/ComfyUI-Easy-Use.git && \
    cd ComfyUI-Easy-Use && \
    pip install -r requirements.txt

# ComfyUI-Florence2 (https://registry.comfy.org/nodes/comfyui-florence2)
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-Florence2.git && \
    cd ComfyUI-Florence2 && \
    pip install -r requirements.txt && \
    mkdir /ComfyUI/models/LLM

# was-node-suite-comfyui (https://registry.comfy.org/nodes/was-node-suite-comfyui)
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/WASasquatch/was-node-suite-comfyui.git && \
    cd was-node-suite-comfyui && \
    pip install -r requirements.txt

# ComfyUI-Logic (https://registry.comfy.org/nodes/comfyui-logic)
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/theUpsider/ComfyUI-Logic.git

# ComfyUI_essentials (https://registry.comfy.org/nodes/comfyui-essentials)
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/cubiq/ComfyUI_essentials.git && \
    cd ComfyUI_essentials && \
    pip install -r requirements.txt

# cg-image-picker (https://registry.comfy.org/nodes/cg-image-picker)
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/chrisgoringe/cg-image-picker.git

# ComfyUI_LayerStyle (https://registry.comfy.org/nodes/comfyui-layerstyle)
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/chflame163/ComfyUI_LayerStyle.git && \
    cd ComfyUI_LayerStyle && \
    pip install -r requirements.txt

# comfyui-mixlab-nodes (https://registry.comfy.org/nodes/comfyui-mixlab-nodes)
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/shadowcz007/comfyui-mixlab-nodes.git && \
    cd comfyui-mixlab-nodes && \
    pip install -r requirements.txt

# comfyui-reactor-node (https://registry.comfy.org/nodes/comfyui-reactor-node)
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/Gourieff/comfyui-reactor-node.git && \
    cd comfyui-reactor-node && \
    pip install -r requirements.txt

# cg-use-everywhere (https://registry.comfy.org/nodes/cg-use-everywhere)
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/chrisgoringe/cg-use-everywhere.git

# ComfyUI-CogVideoXWrapper (https://registry.comfy.org/nodes/comfyui-cogvideoxwrapper)
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-CogVideoXWrapper.git && \
    cd ComfyUI-CogVideoXWrapper && \
    pip install -r requirements.txt

# ComfyUI-FluxTrainer (https://registry.comfy.org/nodes/comfyui-fluxtrainer)
RUN comfy node registry-install comfyui-fluxtrainer

CMD ["conda", "run", "--no-capture-output", "-n", "comfy", "/start.sh" ]
