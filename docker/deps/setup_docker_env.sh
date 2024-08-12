#!/bin/bash

export ISAAC_PATH="/isaac-sim"
export PATH=$PATH:$ISAAC_PATH/kit/python/bin
source $ISAAC_PATH/setup_python_env.sh
export CARB_APP_PATH=$ISAAC_PATH/kit
export EXP_PATH=$ISAAC_PATH/apps
export LD_PRELOAD=$ISAAC_PATH/kit/libcarb.so

alias python=$ISAAC_PATH/python.sh
alias python3=$ISAAC_PATH/python.sh
alias pip='$ISAAC_PATH/python.sh -m pip'
alias pip3='$ISAAC_PATH/python.sh -m pip'
alias tensorboard='$ISAAC_PATH/python.sh $ISAAC_PATH/tensorboard'
