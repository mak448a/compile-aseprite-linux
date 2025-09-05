#!/bin/bash

# Check distro
os_name=$(grep 'NAME=' /etc/os-release | head -n 1 | sed 's/NAME=//' | tr -d '"')


# Return to home directory
cd

# Download skia
wget https://github.com/aseprite/skia/releases/download/m124-08a5439a6b/Skia-Linux-Release-x64.zip
mkdir -p ~/deps/skia
unzip Skia-Linux-Release-x64.zip -d ~/deps/skia
# Clean up zip file
rm Skia-Linux-Release-x64.zip

echo "Warning! Make sure you don't have any directories named aseprite, deps, or Applications/aseprite in your home folder!"
echo "Enter sudo password to install dependencies. This is also a good time to plug in your computer, since compiling will take a long time."


# Assign package manager to a variable
if [[ "$os_name" == *"Fedora"* ]]; then
    package_man="dnf"
elif [[ $os_name == *"Debian"* ]] || [[ $os_name == *"Ubuntu"* ]] || [[ $os_name == *"Mint"* ]]; then
    package_man="apt"
elif [[ $os_name == *"Arch"* ]] || [[ $os_name == *"Manjaro"* ]]; then
    package_man="pacman"
else
    echo "Unsupported distro! If your distro supports APT, DNF, or PACMAN, please manually set os_name='Ubuntu' for apt, os_name='Fedora', or os_name'Arch', at the top of the file. Copy the appropriate command and replace the 'os_name=' with the proper command. You can also open an issue ticket."
    echo "Stopped installation! Please remove ~/deps."
    exit 1
fi

# Install dependencies
if [[ $package_man == "dnf" ]]; then
  sudo dnf install -y gcc-c++ clang libcxx-devel cmake ninja-build libX11-devel libXcursor-devel libXi-devel mesa-libGL-devel fontconfig-devel git
elif [[ $package_man == "apt" ]]; then
  sudo apt-get install -y g++ clang cmake ninja-build libx11-dev libxcursor-dev libxi-dev libgl1-mesa-dev libfontconfig1-dev git
elif [[ $package_man == "pacman" ]]; then
  sudo pacman -S --needed base-devel gcc clang cmake ninja libx11 libxcursor libxi mesa fontconfig git
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
mv aseprite/build/aseprite ~/Applications/
echo "Done compiling!"
echo "The executable is stored in ~/Applications/aseprite. Have fun!"
echo "You can move this folder anywhere."
