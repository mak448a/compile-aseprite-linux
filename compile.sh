#!/bin/sh

cd

# Download skia
wget https://github.com/aseprite/skia/releases/download/m102-861e4743af/Skia-Linux-Release-x64-libc++.zip
mkdir -p ~/deps/skia
unzip Skia-Linux-Release-x64-libc++.zip -d ~/deps/skia
# Clean up zip file
rm Skia-Linux-Release-x64-libc++.zip

# Install deps
echo "Enter sudo password to install dependencies. This is also a good time to plug in your computer, since compiling will take a long time."
sudo dnf install -y gcc-c++ clang libcxx-devel cmake ninja-build libX11-devel libXcursor-devel libXi-devel mesa-libGL-devel fontconfig-devel git

# Clone aseprite
git clone --recursive https://github.com/aseprite/aseprite.git

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
