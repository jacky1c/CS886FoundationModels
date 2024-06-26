#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Please provide a benchmark and an experiment number as arguments."
    echo "Usage: bash script_name.sh <benchmark> <experiment>"
    exit 1
fi

gpuID=$1
portID=$2
benchmark=$3
experiment=$4

# # Setup
# cd /root/InstructBLIP_PEFT
# # Install dependencies
# apt update
# apt install default-jdk -y
# apt install python3.8-venv -y
# python -m venv venv # Create virtual environment
# source venv/bin/activate
# pip install -r requirements.txt

cd /home/rescue/neon/InstructBLIP_PEFT
# conda activate neon

export TORCH_HOME=output/torch
export HUGGINGFACE_HUB_CACHE=output/huggingface

# The directory to copy from
dir=output/results/${benchmark}/${benchmark}_${experiment}
# The directory to copy to
dest=input/results/${benchmark}/${benchmark}_${experiment}

mkdir -p $dir
mkdir -p $dest
touch $dir/${benchmark}_${experiment}.log
CUDA_VISIBLE_DEVICES=${gpuID} python3 -m torch.distributed.run --nproc_per_node=1 --master_port ${portID} train.py --cfg-path lavis/projects/instructblip/train/${benchmark}/finetune_instructblip_${benchmark}_${experiment}.yaml 2>&1 | tee $dir/${benchmark}_$experiment.log

rsync -av --no-o --no-g --chmod=777 --exclude='*.pth' $dir/ $dest/
