#!/bin/sh

wget https://github.com/aseprite/skia/releases/download/m102-861e4743af/Skia-Linux-Release-x64-libc++.zip

mkdir -p ~/deps/skia
unzip Skia-Linux-Release-x64-libc++.zip -d ~/deps/skia

rm Skia-Linux-Release-x64-libc++.zip
