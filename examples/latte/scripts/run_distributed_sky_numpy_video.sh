#!/bin/bash
if [ $# != 3 ]
then
    echo "For distributed training in single/multiple machine with Ascend devices."
    echo "Usage Help: bash run_distributed_sky_numpy_video.sh [RANK_TABLE_FILE] [RANK_START] [RANK_SIZE]"
    echo "Example as: bash run_distributed_sky_numpy_video.sh hccl_4p.json 4 4"
    echo "[RANK_TABLE_FILE]: HCCL config file, please visit https://gitee.com/mindspore/models/tree/master/utils/hccl_tools"
    echo "[RANK_START]: The starting device ID."
    echo "[RANK_SIZE]: The total number of distributed processes you want to launch."
    exit 1
fi

set -e
export RANK_TABLE_FILE=$1
START_DEVICE=$2
RANK_SIZE=$3
DEVICE_NUM=8  # default 8 cards in one machine

# MS <= 2.2
export MS_ASCEND_CHECK_OVERFLOW_MODE="INFNAN_MODE"


for ((i = 0; i < ${RANK_SIZE}; i++)); do
    export DEVICE_ID=$((i + ${START_DEVICE}))
    export RANK_ID=$i
    echo "Launching rank: ${RANK_ID}, device: ${DEVICE_ID}"
    if [ $i -eq 0 ]; then
        python train.py \
            -c configs/training/sky_numpy_video.yaml \
            --use_parallel True > train.log 2>&1 &
    else
        python train.py \
            -c configs/training/sky_numpy_video.yaml \
            --use_parallel True > /dev/null 2>&1 &
    fi
done

echo "Distributed training is launched. Terminal output is saved at 'train.log'. "
