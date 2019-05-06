#!/bin/bash

set -ex

PROTOBUF_UE4_PREFIX=/mnt/h/protobuf/build
UE4_ROOT=/mnt/f/UnrealEngine

if [[ -z "${PROTOBUF_UE4_PREFIX}" ]]; then
  echo "PROTOBUF_UE4_PREFIX is not set, exit."
  exit 1
else
  echo "PROTOBUF_UE4_PREFIX: ${PROTOBUF_UE4_PREFIX}"
fi


if [[ -z "${UE4_ROOT}" ]]; then
  echo "UE4_ROOT is not set, exit."
  exit 1
else
  echo "UE4_ROOT: ${UE4_ROOT}"
fi

if [[ -d "${UE4_ROOT}" ]]; then
  echo "ok: UE4_ROOT exist."
else
  echo "error: UE4_ROOT no exist."
fi

cd ..
PROTOBUF_DIR=`pwd`
OUT_PATH=${PROTOBUF_DIR}/temp
rm -rf ${OUT_PATH}
mkdir -p ${OUT_PATH}

CLANG_TOOLCHAIN=/mnt/c/UnrealToolchains/v13_clang-7.0.1-centos7/x86_64-unknown-linux-gnu


export CC=/usr/bin/clang-7
export CXX=/usr/bin/clang++-7
export UE4_LIBCXX_ROOT=${UE4_ROOT}/Engine/Source/ThirdParty/Linux/LibCxx
export CXXFLAGS="-fPIC                    \
  -O2                                     \
  -DNDEBUG                                \
  -Wno-unused-command-line-argument       \
  -nostdinc++                             \
  -I${UE4_LIBCXX_ROOT}/include            \
  -I${UE4_LIBCXX_ROOT}/include/c++/v1" 
export LDFLAGS="-L${UE4_LIBCXX_ROOT}/lib/Linux/x86_64-unknown-linux-gnu"
export LIBS="-lc++ -lc++abi"

# static
./autogen.sh
./configure                               \
  --disable-shared                        \
  --disable-debug                         \
  --disable-dependency-tracking           \
  --prefix="${OUT_PATH}/build"

make -j$(nproc)
#make check
make install

rm -rf ${PROTOBUF_UE4_PREFIX}/linux
mkdir -p ${PROTOBUF_UE4_PREFIX}/linux/lib

mv ${OUT_PATH}/build/lib/libprotobuf.a ${PROTOBUF_UE4_PREFIX}/linux/lib/libprotobuf.a

rm -rf ${OUT_PATH}/build

objdump -h ${PROTOBUF_UE4_PREFIX}/linux/lib/libprotobuf.a | head -n 25