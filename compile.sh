#!/bin/bash

[[ -z "${XDG_DATA_HOME}" ]] && XDG_DATA_HOME="${HOME}/.local/share"

INSTALL_DIR="${XDG_DATA_HOME}/aseprite"

SIGNATURE_FILE="${INSTALL_DIR}/compile-aseprite-linux"

if [[ -f "${SIGNATURE_FILE}" ]] ; then
    read -e -p "aseprite already installed. update? (y/n): " choice
    [[ "${choice}" == [Yy]* ]] \
        || exit 0
else
    [[ -d "${INSTALL_DIR}" ]] \
        && { echo "aseprite already installed to '${INSTALL_DIR}'. aborting" >&2 ; exit 1 ; }
fi

WORK_DIR=$(mktemp -d -t 'compile-aseprite-linux-XXXXX') \
    || { echo "unable to create temp folder" >&2 ; exit 1 ; }

cleanup() {
    code=$?
    echo "cleaning up"
    pushd -0
    dirs -c
    rm -rf "${WORK_DIR}"
    exit "${code}"
}

trap "cleanup" EXIT

pushd "${WORK_DIR}"

# Check distro
os_name=$(grep 'NAME=' /etc/os-release | head -n 1 | sed 's/NAME=//' | tr -d '"')

# Download skia
wget https://github.com/aseprite/skia/releases/download/m102-861e4743af/Skia-Linux-Release-x64-libc++.zip
mkdir ./skia
unzip Skia-Linux-Release-x64-libc++.zip -d ./skia

echo "Enter sudo password to install dependencies. This is also a good time to plug in your computer, since compiling will take a long time."


# Assign package manager to a variable
if [[ "$os_name" == *"Fedora"* ]]; then
    package_man="dnf"
elif [[ $os_name == *"Debian"* ]] || [[ $os_name == *"Ubuntu"* ]] || [[ $os_name == *"Mint"* ]]; then
    package_man="apt"
else
    echo "Unsupported distro! If your distro supports APT or DNF, please manually set os_name='Ubuntu' for apt, or os_name='Fedora' at the top of the file. Copy the appropriate command and replace the 'os_name=' with the proper command. You can also open an issue ticket."
    echo "Stopped installation! Please remove ~/deps."
    exit 1
fi

# Install dependencies
if [[ $package_man == "dnf" ]]; then
  sudo dnf install -y gcc-c++ clang libcxx-devel cmake ninja-build libX11-devel libXcursor-devel libXi-devel mesa-libGL-devel fontconfig-devel git
elif [[ $package_man == "apt" ]]; then
  sudo apt-get install -y g++ clang libc++-dev libc++abi-dev cmake ninja-build libx11-dev libxcursor-dev libxi-dev libgl1-mesa-dev libfontconfig1-dev git
fi

# Clone aseprite
git clone --recursive https://github.com/aseprite/aseprite.git --depth=1

echo "Finished downloading! Time to compile."

mkdir aseprite/build
pushd aseprite/build
export CC=clang
export CXX=clang++
cmake \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_CXX_FLAGS:STRING=-stdlib=libc++ \
  -DCMAKE_EXE_LINKER_FLAGS:STRING=-stdlib=libc++ \
  -DLAF_BACKEND=skia \
  -DSKIA_DIR="${WORK_DIR}/skia" \
  -DSKIA_LIBRARY_DIR="${WORK_DIR}/skia/out/Release-x64" \
  -DSKIA_LIBRARY="${WORK_DIR}/skia/out/Release-x64/libskia.a" \
  -G Ninja \
  ..
ninja aseprite
popd

rm -rf "${INSTALL_DIR}" \
    || { echo "unable to clean up old install" >&2 ; exit 1 ; }
mkdir -p "${INSTALL_DIR}" \
    || { echo "unable to create install folder" >&2 ; exit 1 ; }

mv aseprite/build/bin/* "${INSTALL_DIR}"
touch "${SIGNATURE_FILE}"

echo "Done compiling!"
echo "The executable is stored in '${INSTALL_DIR}'. Have fun!"
