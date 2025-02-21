#!/bin/bash

echo "pod started"

if [[ $PUBLIC_KEY ]]
then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    cd ~/.ssh
    echo $PUBLIC_KEY >> authorized_keys
    chmod 700 -R ~/.ssh
    cd /
    service ssh start
fi

#!/bin/bash
if [[ -z "${HF_TOKEN}" ]] || [[ "${HF_TOKEN}" == "enter_your_huggingface_token_here" ]]
then
    echo "HF_TOKEN is not set"
else
    echo "HF_TOKEN is set, logging in..."
    huggingface-cli login --token ${HF_TOKEN}
fi


# Start nginx as reverse proxy to enable api access
service nginx start

# Check if the flux model is present
bash /check_files.sh

# Activate conda environment
source /usr/local/miniconda3/etc/profile.d/conda.sh
conda activate comfy

# Check if user's script exists in /opt
if [ ! -f /opt/comfy/start_user.sh ]; then
    # If not, copy the original script to /opt
    cp /start-original.sh /opt/comfy/start_user.sh
fi

# Execute the user's script
bash /opt/comfy/start_user.sh

sleep infinity
