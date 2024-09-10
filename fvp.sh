#!/usr/bin/env bash

MODEL="$(basename "$0")"
DIRNAME="$(dirname "$(realpath "$0")")"

source "${DIRNAME}/fvprc"

FLAGS=("$@")
PORTS=()
if [[ "${FLAGS[*]}" =~ "-I" || "${FLAGS[*]}" =~ "--iris-server" ]]; then
    PORTS+=("-p" "7100:7100")
    if [[ ! "${FLAGS[*]}" =~ "--print-port-number" && ! "${FLAGS[*]}" =~ "-p" ]]; then
        FLAGS+=("--print-port-number")
    fi
    if [[ ! "${FLAGS[*]}" =~ "--iris-allow-remote" && ! "${FLAGS[*]}" =~ "-A" ]]; then
        FLAGS+=("--iris-allow-remote")
    fi
fi

if ! docker image inspect "fvp:${FVP_VERSION}" >/dev/null 2>&1; then
    "${DIRNAME}/build.sh"
fi

# Define the default mounts
MOUNTS=("--mount" "type=bind,src=${HOME}/.armlm/,dst=${HOME}/.armlm/")

# Add the FVP_MAC_WORKDIR mount if the variable is set
if [ -n "$FVP_MAC_WORKDIR" ]; then
    MOUNTS+=("--mount" "type=bind,src=${FVP_MAC_WORKDIR},dst=${FVP_MAC_WORKDIR}")
fi

docker run "${PORTS[@]}" "${MOUNTS[@]}" -w "$(pwd)" -e "ARMLM_CACHED_LICENSES_LOCATION=${HOME}/.armlm" -e "FVP_MAC_WORKDIR=${FVP_MAC_WORKDIR}" "fvp:${FVP_VERSION}" "${MODEL}" "${FLAGS[@]}"

exit
