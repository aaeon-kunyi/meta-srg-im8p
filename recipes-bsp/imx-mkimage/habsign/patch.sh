#!/bin/bash

set -euo pipefail
dd if=$1 of=$2 seek=$(( $3 )) bs=1 conv=notrunc
