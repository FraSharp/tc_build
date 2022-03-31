#!/usr/bin/env bash

BASE=$(dirname "$(readlink -f "${0}")")

set -eu

function parse_parameters() {
    while ((${#})); do
        case ${1} in
            all | binutils | deps | llvm) ACTION=${1} ;;
            *) exit 33 ;;
        esac
        shift
    done
}

function do_all() {
    do_deps
    do_llvm
    do_binutils
}

function do_binutils() {
    "${BASE}"/build-binutils.py -t aarch64
}

function do_deps() {
    # We only run this when running on GitHub Actions
    [[ -z ${GITHUB_ACTIONS:-} ]] && return 0
    sudo apt-get install -y --no-install-recommends \
        bc \
        bison \
        ca-certificates \
        clang \
        cmake \
        curl \
        file \
        flex \
        gcc \
        g++ \
        git \
        libelf-dev \
        libssl-dev \
        lld \
        make \
        ninja-build \
        python3 \
        texinfo \
        xz-utils \
        zlib1g-dev
}

function do_llvm() {
    EXTRA_ARGS=()
    [[ -n ${GITHUB_ACTIONS:-} ]] && EXTRA_ARGS+=(--no-ccache)
    "${BASE}"/build-llvm.py \
	--use-good-revision \
        --projects "clang;lld;polly" \
        --shallow-clone \
        --targets "AArch64" \
        --pgo kernel-defconfig \
        --lto full \
        "${EXTRA_ARGS[@]}"
}

parse_parameters "${@}"
do_"${ACTION:=all}"
