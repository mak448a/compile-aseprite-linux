#!/bin/bash

[[ -z "${XDG_DATA_HOME}" ]] && XDG_DATA_HOME="${HOME}/.local/share"

INSTALL_DIR="${XDG_DATA_HOME}/aseprite"
BINARY_DIR="${HOME}/.local/bin"
LAUNCHER_DIR="${XDG_DATA_HOME}/applications"
ICON_DIR="${XDG_DATA_HOME}/icons"

SIGNATURE_FILE="${INSTALL_DIR}/compile-aseprite-linux"
BINARY_FILE="${BINARY_DIR}/aseprite"
LAUNCHER_FILE="${LAUNCHER_DIR}/aseprite.desktop"
ICON_FILE="${ICON_DIR}/aseprite.png"

if [[ -f "${SIGNATURE_FILE}" ]] ; then
    read -e -p "Aseprite already installed. Update? (y/n): " choice
    [[ "${choice}" == [Yy]* ]] \
        || exit 0
else
    [[ -d "${INSTALL_DIR}" ]] \
        && { echo "Aseprite already installed to '${INSTALL_DIR}'. Aborting" >&2 ; exit 1 ; }
    { [[ -f "${LAUNCHER_FILE}" ]] || [[ -f "${BINARY_FILE}" ]] || [[ -f "${ICON_FILE}" ]] ; } \
        && { echo "Other aseprite data already installed to home directory. Aborting" >&2 ; exit 1 ; }
fi

if [[ -z "${TESTING}" ]] ; then
    WORK_DIR=$(mktemp -d -t 'compile-aseprite-linux-XXXXX') \
        || { echo "Unable to create temp folder" >&2 ; exit 1 ; }
else
    WORK_DIR='compile-aseprite-linux-testing'
    mkdir -p "${WORK_DIR}"
fi
WORK_DIR="$(realpath "${WORK_DIR}")"

cleanup() {
    code=$?
    echo "Cleaning up."
    pushd -0 >/dev/null
    dirs -c
    if [[ -z "${TESTING}" ]] ; then
        rm -rf "${WORK_DIR}"
    fi
    exit "${code}"
}

trap "cleanup" EXIT

pushd "${WORK_DIR}"

# Check distro
os_name=$(grep 'NAME=' /etc/os-release | head -n 1 | sed 's/NAME=//' | tr -d '"')

echo "Enter sudo password to install dependencies. This is also a good time to plug in your computer, since compiling will take a long time."

# Assign package manager to a variable
if [[ "$os_name" == *"Fedora"* ]]; then
    package_man="dnf"
elif [[ $os_name == *"Debian"* ]] || [[ $os_name == *"Ubuntu"* ]] || [[ $os_name == *"Mint"* ]]; then
    package_man="apt"
else
    echo "Unsupported distro! If your distro supports APT or DNF, please manually modify the script to set os_name='Ubuntu' for apt, or os_name='Fedora'. You can also open an issue ticket."
    echo "Stopped installation!"
    exit 1
fi

# Install dependencies
if [[ $package_man == "dnf" ]]; then
    sudo dnf install -y git \
        gcc-c++ clang libcxx-devel cmake ninja-build libX11-devel libXcursor-devel libXi-devel libXrandr-devel mesa-libGL-devel fontconfig-devel
elif [[ $package_man == "apt" ]]; then
    sudo apt-get install -y git\
        g++ clang cmake ninja-build libx11-dev libxcursor-dev libxi-dev libxrandr-dev libgl1-mesa-dev libfontconfig1-dev
fi

[[ $? == 0 ]] \
    || { echo "Failed to install dependencies." >&2 ; exit 1 ; }

# Clone aseprite
git clone --recursive https://github.com/aseprite/aseprite.git --depth=1 \
    || { echo "Unable to clone Aseprite repo." >&2 ; exit 1 ; }

# Download skia
wget -O skia.zip https://github.com/aseprite/skia/releases/download/m124-08a5439a6b/Skia-Linux-Release-x64.zip \
    || { echo "Failed to download skia." >&2 ; exit 1 ; }
mkdir ./skia && unzip skia.zip -d ./skia \
    || { echo "Failed to extract skia." >&2 ; exit 1 ; }

echo "Finished downloading! Time to compile."

mkdir aseprite/build \
    || { echo "Failed create build folder." >&2 ; exit 1 ; }
pushd aseprite/build

export CC=clang
export CXX=clang++
cmake \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_CXX_FLAGS:STRING=-stdlib=libstdc++ \
    -DCMAKE_EXE_LINKER_FLAGS:STRING=-stdlib=libstdc++ \
    -DLAF_BACKEND=skia \
    -DSKIA_DIR="${WORK_DIR}/skia" \
    -DSKIA_LIBRARY_DIR="${WORK_DIR}/skia/out/Release-x64" \
    -DSKIA_LIBRARY="${WORK_DIR}/skia/out/Release-x64/libskia.a" \
    -G Ninja \
    .. \
    || { echo "Configuration failed." >&2 ; exit 1 ; }

ninja aseprite \
    || { echo "Compilation failed." >&2 ; exit 1 ; }

popd

rm -rf "${INSTALL_DIR}" \
    || { echo "Unable to clean up old install." >&2 ; exit 1 ; }
mkdir -p "${INSTALL_DIR}" "${BINARY_DIR}" "${LAUNCHER_DIR}" "${ICON_DIR}" \
    || { echo "Unable to create install folder." >&2 ; exit 1 ; }

{ mv aseprite/build/bin/* "${INSTALL_DIR}" \
    && touch "${SIGNATURE_FILE}" \
    && ln -sf "${INSTALL_DIR}/aseprite" "${BINARY_FILE}" \
    && ln -sf "${INSTALL_DIR}/data/icons/ase256.png" "${ICON_FILE}" \
    && cp -f "${WORK_DIR}/aseprite/src/desktop/linux/aseprite.desktop" "${LAUNCHER_FILE}" \
; } || { echo "Failed to complete install." >&2 ; exit 1 ; }

echo "Done compiling!"
echo "The executable is stored in '${INSTALL_DIR}'. Have fun!"
