# Compile Aseprite on Fedora
Here's how to compile aseprite for free on Fedora 37. If you want to support the developers out, buy it on their website: https://aseprite.org

## Clone repo
```shell
git clone --recursive https://github.com/aseprite/aseprite.git
```

## Download dependencies
```shell
sudo dnf install -y gcc-c++ clang libcxx-devel cmake ninja-build libX11-devel libXcursor-devel libXi-devel mesa-libGL-devel fontconfig-devel
```
1. Download the latest version of skia from here: https://github.com/aseprite/skia/releases
2. Note: VERY IMPORTANT! Download Skia-Linux-Release-x64-libc++.zip, not Skia-Linux-Release-x64-libstdc++.zip. If you download the wrong one, the whole build will fail.
3. Extract the file
4. Move extracted folder to ~/deps/skia

## Compile the code!
```shell
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
```


## Where is the executable?
The executable is stored in aseprite/build/bin. Have fun!
