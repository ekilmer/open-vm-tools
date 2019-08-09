#!/usr/bin/env bash

set -e

cd open-vm-tools
autoreconf -i
./configure --without-kernel-modules
make -j"$(nprocs)"
