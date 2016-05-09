# Atelier gestion de données PointCloud

## Présentation générale

- Oslandia
- Logistique
- Environnement

## Les concepts et les technologies utilisées

- Lidar et nuage de points
- Éléments de volumétrie
- Technologies :
  - PostGIS
  - PgPointcloud (schémas, pacths, types, ...)
  - PDAL (pipeline, filtre, writers, ...)
  - PgAdmin
  - QGIS
- Conclusion

## Déroulé de l'atelier

### Étape 1

Utilisation des LAStools (las2las, lasinfo, las2txt).

### Étape 2

PGPointCloud et PgAdmin (*Navigateur d'objets* et *Éditeur de requêtes*).

### Étape 3

- Visualiser la couverture des données avec QGIS
- Database manager
- Requêtes "basiques" sur le nuage de point (filtrages, stats basiques)
  - Extraction d'une zone polygonale
  - Calculs de moyennes, max et min sur la zone
  - Trouver la hauteur du Puy-de-Dôme
  - Enveloppes convexes/concaves des points par tranche d'altitude

## Les données utilisées

Nous utiliserons les données du CRAIG, sur la zone de Clermont Ferrand, ainsi que des données OpenStreetMap.

Le CRAIG offre un éventail large de données en OpenData, comme on peut le voir dans le catalogue : 
- http://ids.craig.fr/geocat/srv/eng/catalog.search

Sont notamment offertes des données LIDAR sur différentes zones. On peut notamment les visualiser directement en ligne ici :
- http://ids.craig.fr/carto/?wmc=contexts/dallage_opendata.wmc

Et le FTP permet de télécharger les données brutes :
- ftp://opendata.craig.fr/opendata/

Par ailleurs, des webservices sont proposés, accessibles sur cette page :
- http://ids.craig.fr/wxs/web/

On utilisera notamment les couches WMS pour avoir un fond de plan dans QGIS :
- http://ids.craig.fr/wxs/ows?service=wms&version=1.1.1&request=GetCapabilities

Pour les données OSM, nous utiliserons les exports offerts par GeoFabrik, en téléchargeant et intégrant la donnée pour l'Auvergne :
- http://download.geofabrik.de/europe/france.html
- Auvergne SHP : http://download.geofabrik.de/europe/france/auvergne-latest.shp.zip
