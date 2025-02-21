#!/bin/bash

# Ensure we have /workspace in all scenarios
mkdir -p /workspace

if [[ ! -d /workspace/comfy ]]; then
	# If we don't already have /workspace/comfy, move it there
	mv /comfy /workspace
else
	# otherwise delete the default ComfyUI folder which is always re-created on pod start from the Docker
	rm -rf /comfy
fi

# Then link /comfy folder to /workspace so it's available in that familiar location as well
ln -s /workspace/comfy /comfy
