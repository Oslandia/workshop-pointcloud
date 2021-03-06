To install all dependencies required to run this workshop, you can use the provided install script, or follow all detailed instructions below.

# Full install

Run on the command line in the workshop directory : 

```bash
sudo sh en/deps/install_deps.sh
```

Once the installation is over, you can go to Step 1 of the workshop.

# libLAS

## LASzip

In order to have the LAZ support in libLAS, we need to compile LASzip.

As root ( `sudo -s` ) :

```bash
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
```

## libLAS

Then we can compile libLAS with LASzip support:

```bash
cd /usr/local/src
git clone https://github.com/libLAS/libLAS
cd libLAS
mkdir build
cd build
cmake .. -DWITH_LASZIP=ON
make
make install
```

In our case, lastools (las2las, las2txt, lasinfo, ...) are provided by libLAS.


# PDAL

To compile PDAL with LAZ support, LASzip is necessary.

As root ( `sudo -s` ) :

```bash
cd /usr/local/src
git clone https://github.com/PDAL/PDAL
cd PDAL
mkdir build
cd build
cmake -DWITH_LASZIP=ON -DBUILD_PLUGIN_PGPOINTCLOUD=ON ..
make
make install
```
