#!/bin/bash

os_name=$(grep 'NAME=' /etc/os-release | head -n 1 | sed 's/NAME=//' | tr -d '"')


# Return to home directory
cd

# Download skia
wget https://github.com/aseprite/skia/releases/download/m102-861e4743af/Skia-Linux-Release-x64-libc++.zip
mkdir -p ~/deps/skia
unzip Skia-Linux-Release-x64-libc++.zip -d ~/deps/skia
# Clean up zip file
rm Skia-Linux-Release-x64-libc++.zip


echo "Enter sudo password to install dependencies. This is also a good time to plug in your computer, since compiling will take a long time."

# Check distro
os_name=$(grep '^ID=' /etc/os-release --max-count 1 | cut -c4-)
os_like=$(grep '^ID_LIKE=' /etc/os-release --max-count 1 | cut -c9-)
os_variant=$(grep '^VARIANT_ID=' /etc/os-release --max-count 1 | cut -c12-)

# replace 'ubuntu' with 'debian' and 'rhel' with 'fedora' (among others)
# this has some weird issues on some distros where they list multiple possibilities
# https://github.com/which-distro/os-release/
[[ "$os_like" =~ [[:space:]]+ ]] && os_like=''
[[ "$os_like" != '' ]] && os_name="$os_like"

case "$os_name" in
'debian' | 'ubuntu' | 'linuxmint')
    package_man='apt'
    ;;
'fedora')
    case "$os_variant" in
    'kinoite' | 'silverblue')
        package_man='unsupported'
        ;;
    *)
        package_man='dnf'
        ;;
    esac
    ;;
'arch')
    package_man='unsupported' # for now
    ;;
*)
    package_man="unknown"
    ;;
esac

# user override
if [[ "$PACKAGE_MANAGER" != "" ]] ; then
    package_man="$PACKAGE_MANAGER"
fi

package_manager_text="Currently this script only supports apt and dnf, and it appears that your system is unsupported.
If you believe this is a mistake, please re-run this script with environmental variable 'PACKAGE_MANAGER=apt' or 'PACKAGE_MANAGER=dnf'.
You can also open an issue ticket."

# Install dependencies
case "$package_man" in
'dnf')
    sudo dnf install -y gcc-c++ clang libcxx-devel cmake ninja-build libX11-devel libXcursor-devel libXi-devel mesa-libGL-devel fontconfig-devel git
    ;;
'apt')
    sudo apt-get install -y g++ clang libc++-dev libc++abi-dev cmake ninja-build libx11-dev libxcursor-dev libxi-dev libgl1-mesa-dev libfontconfig1-dev git
    ;;
'pacman') # untested
    sudo pacman -S gcc clang libc++ cmake ninja libx11 libxcursor mesa-libgl fontconfig libwebp
    ;;
'zypper') # untested
    sudo zypper install gcc-c++ clang libc++-devel libc++abi-devel cmake ninja libX11-devel libXcursor-devel libXi-devel Mesa-libGL-devel fontconfig-devel
    ;;
'unsupported')
    echo "Unsupported distro!"
    echo "$package_manager_text"
    exit 1
    ;;
*)
    echo "Unknown distro!"
    echo "$package_manager_text"
    exit 1
    ;;
esac

# Clone aseprite
git clone --recursive https://github.com/aseprite/aseprite.git --depth=1

echo "Finished downloading! Time to compile."

cd aseprite
mkdir build
cd build
export CC=clang
export CXX=clang++
cmake \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_CXX_FLAGS:STRING=-stdlib=libc++ \
  -DCMAKE_EXE_LINKER_FLAGS:STRING=-stdlib=libc++ \
  -DLAF_BACKEND=skia \
  -DSKIA_DIR=$HOME/deps/skia \
  -DSKIA_LIBRARY_DIR=$HOME/deps/skia/out/Release-x64 \
  -DSKIA_LIBRARY=$HOME/deps/skia/out/Release-x64/libskia.a \
  -G Ninja \
  ..
ninja aseprite

# Cleanup
cd
rm -rf deps

mkdir -p Applications/aseprite

mv aseprite/build/bin aseprite/build/aseprite
mv aseprite/build/aseprite ~/Applications/aseprite
echo "Done compiling!"
echo "The executable is stored in ~/Applications/aseprite. Have fun!"
echo "You can move this folder anywhere."
