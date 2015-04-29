#!/bin/bash

set -e

# Get the number of available cores to speed up the builds
COUNT_CORES=`grep -c ^processor /proc/cpuinfo`
echo "Will use $COUNT_CORES parallel jobs to build Orthanc"

# Clone the repository and switch to the requested branch
cd /home/
hg clone https://bitbucket.org/sjodogne/orthanc-dicomweb
cd orthanc-dicomweb
hg up -c "$1"

# Build the plugin
mkdir Build
cd Build
cmake -DALLOW_DOWNLOADS:BOOL=ON \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DUSE_GTEST_DEBIAN_SOURCE_PACKAGE:BOOL=ON \
    -DUSE_SYSTEM_JSONCPP:BOOL=OFF \
    -DUSE_SYSTEM_PUGIXML:BOOL=OFF \
    ..
make -j$COUNT_CORES
./UnitTests
cp -L libOrthancDicomWeb.so /usr/share/orthanc/plugins/

# Remove the build directory to recover space
cd /home/
rm -rf /home/orthanc-dicomweb