# Point Cloud Workshop

## Introduction

- Oslandia - for all additional information, support or question, please contact infos+3d@oslandia.com
- Logistic
- Working environment

## Things to do first

In order not to loose time, we will take some actions first. Open a terminal and run the following commands.

```bash
wget -O workshop.zip https://codeload.github.com/Oslandia/workshop-pointcloud/zip/master
unzip workshop.zip
sudo sh workshop-pointcloud-master/en/deps/install_deps.sh
```

## Concepts and technologies

- LIDAR and point cloud
- Amount of data
- Technologies :
  - PostGIS
  - pgpointcloud (schemas, pacths, types, ...)
  - PDAL (pipeline, filter, writers, ...)
  - pgAdmin
  - QGIS
- Conclusion

## Proceedings

### Step 1

Use of libLAS tools (las2las, lasinfo, las2txt).

### Step 2

Use of the PDAL pipeline.

### Step 3

pgpointcloud and pgAdmin (*Object Browsers* and *Query Tool*).

### Step 4

- See the LIDAR data coverage through QGIS
- Database manager
- Simple queries to work with the point cloud (filtering, statistical data)
  - Cropping
  - Average, max and min computation
  - Retrieve the altitude of the Puy-de-Dôme
  - Convex and concave hull per altitude levels

## Data

We'll use data from CRAIG on Clermont Ferrand area as well as data coming from OpenStreetMap.

CRAIG provides a wide range of Open Data, as can be seen in the catalogue:
- http://ids.craig.fr/geocat/srv/eng/catalog.search

In particular, some LIDAR data are provided on several areas. These can be directly viewed online within your web browser:
- http://ids.craig.fr/carto/?wmc=contexts/dallage_opendata.wmc

And the FTP allows to download these data:
- ftp://opendata.craig.fr/opendata/

Moreover, some webservices are available and provided on the below web page:
- http://ids.craig.fr/wxs/web/

Otherwise, we'll use WMS layers to display a base map within QGIS:
- http://ids.craig.fr/wxs/ows?service=wms&version=1.1.1&request=GetCapabilities

About OSM data, we'll use exported data provided by GeoFabrik, downloading and using data on the Auvergne area:
- http://download.geofabrik.de/europe/france.html
- Auvergne SHP : http://download.geofabrik.de/europe/france/auvergne-latest.shp.zip
