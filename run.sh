#!/usr/bin/env bash

set -eu -o pipefail

echo "=== build kaldi ==="
(
    set -eu -o pipefail

    mkdir kaldi
    cd kaldi
    git init
    git fetch --depth=1 git://github.com/kaldi-asr/kaldi 29b3265104fc10ce3e06bfacb8f1e7ef9f16e3be
    git checkout FETCH_HEAD

    (
        set -eu -o pipefail

        cd tools
        ./extras/check_dependencies.sh
        if [ "$(uname -s)" == 'Linux' ]; then
            sudo ./extras/install_mkl.sh
        else
            extras/install_openblas.sh
        fi
        CC=gcc CXX=g++ make -j4
    )
    (
        set -eu -o pipefail

        cd src
        if [ "$(uname -s)" == 'Linux' ]; then
            ./configure --static --use-cuda=no # --mathlib=OPENBLAS
        else
            ./configure --static --use-cuda=no --mathlib=OPENBLAS
        fi
        CC=gcc CXX=g++ make -j4 depend
        cd featbin
        make -j4
    )
)

