#!/bin/sh

# Check distro
os_name=$(grep 'NAME=' /etc/os-release | head -n 1 | sed 's/NAME=//' | tr -d '"')
os_name="Ubuntu"

# Return to home directory
cd

# Download skia
wget https://github.com/aseprite/skia/releases/download/m102-861e4743af/Skia-Linux-Release-x64-libc++.zip
mkdir -p ~/deps/skia
unzip Skia-Linux-Release-x64-libc++.zip -d ~/deps/skia
# Clean up zip file
rm Skia-Linux-Release-x64-libc++.zip


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
  sudo apt-get install -y g++ clang libc++-dev libc++abi-dev cmake ninja-build libx11-dev libxcursor-dev libxi-dev libgl1-mesa-dev libfontconfig1-dev
fi

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
