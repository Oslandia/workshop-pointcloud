# LAStools

## LASzip

Pour avoir le support LAZ dans LAStools, il faut dans un premier temps compiler
LASzip :

```bash
cd /usr/local/src
git clone https://github.com/LASzip/LASzip
git checkout debian-config
mkdir build
cd build
cmake ..
make
make install
```

## libLAS

Puis compiler libLAS avec le support LASzip :

```bash
cd /usr/local/src
git clone https://github.com/libLAS/libLAS
mkdir build
cd build
cmake .. -DWITH_LASZIP=ON
make
make install
```

Ici, c'est libLAS qui fournis les LAStools (las2las, las2txt, lasinfo, ...).
