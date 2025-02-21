#!/bin/bash
dir="/opt/comfy/custom_nodes/comfy-mixlab-nodes"

if [ -d "$dir" ]
then
    mv "$dir" "$dir.disabled"
    echo "Mixlab nodes has been disabled successfully."
fi
