#!/bin/sh

cd

# Download skia
wget https://github.com/aseprite/skia/releases/download/m102-861e4743af/Skia-Linux-Release-x64-libc++.zip
mkdir -p ~/deps/skia
unzip Skia-Linux-Release-x64-libc++.zip -d ~/deps/skia
# Clean up zip file
rm Skia-Linux-Release-x64-libc++.zip

# Clone aseprite
git clone --recursive https://github.com/aseprite/aseprite.git

# Install deps
sudo dnf install -y gcc-c++ clang libcxx-devel cmake ninja-build libX11-devel libXcursor-devel libXi-devel mesa-libGL-devel fontconfig-devel
