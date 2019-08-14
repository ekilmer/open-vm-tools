#!/bin/sh

set -e

cd open-vm-tools
autoreconf -i
./configure --without-kernel-modules --without-dnet
make -j"$(nprocs)"
