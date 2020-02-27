#!/bin/bash
set -x
. ./func/DownBuild.sh
DBuild 1 192.168.3.106 7_5_0_a18 7_5_0_a5
set +x
