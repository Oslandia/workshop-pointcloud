#!/bin/sh

# LASzip
cd /usr/local/src
git clone https://github.com/LASzip/LASzip
cd LASzip
git checkout debian-config
mkdir build
cd build
cmake ..
make
make install
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/local/lib" >> ~user/.bashrc


# LibLAS
cd /usr/local/src
git clone https://github.com/libLAS/libLAS
cd libLAS
mkdir build
cd build
cmake .. -DWITH_LASZIP=ON
make
make install

# PDAL
cd /usr/local/src
git clone https://github.com/PDAL/PDAL
cd PDAL
mkdir build
cd build
cmake -DWITH_LASZIP=ON -DBUILD_PLUGIN_PGPOINTCLOUD=ON ..
make
make install
