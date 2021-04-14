#! /bin/bash

# Setup display
Xvfb :99 &
export DISPLAY=:99

exec $@