# QGIS

Pour cette troisième étape, nous allons travailler avec QGIS pour visualiser
les données. Nous allons aussi faire quelques requêtes SQL plus complexes afin
d'obtenir des informations comme par exemple l'altitude du Puy-De-Dôme.

## Ajouter une couche PostGIS

Dans un premier temps, lancez le logiciel QGIS. Suite à cela, ajoutez une couche
PostGIS via *Couche -> Ajouter une couche -> Ajouter une couche PostGIS*.
Ensuite cliquez sur le bouton *Nouveau* pour créer une nouvelle connexion et
remplissez les informations de connexion (comme précédement avec pgAdmin).

Puis, validez avec *OK*, lancez la connexion avec le bouton *Connect*.
Ensuite sélectionnez les couches en déroulant *public* et appuyez sur le bouton
*Ajouter*.

![alt text][conn]
[conn]: imgs/conn.png "Connexion"

Les données doivent alors se charger dans le canvas QGIS et vous devriez
obetnir quelque comme ci dessous (modulo les couleurs).

![alt text][data]
[data]: imgs/data.png "Données"

## Les données lidar

Nous pouvons afficher seulement des couches de données spécifiques en
cochant/décochant des couches dans l'arbre QGIS.

![alt text][tree]
[tree]: imgs/tree.png "Arbre de couches"

Si nous cochons simplement la couche *lidar* (qui représente les données de la
table *lidar* contenant des *pcpatch* comme vu à l'étape 2) nous observons très
bien les patchs issus du filtre *chipper* de PDAL :

![alt text][patchs]
[patchs]: imgs/pcpatch.png "Patchs"

## Gestionnaire de base de données

Nous allons maintenant utiliser le *Gestionnaire de base de données* pour lancer
des requêtes SQL.

Pour l'ouvrir, cliquez sur
*Base de données -> Gestionnaire de base de données -> Gestionnaire de base de données*.
Ensuite, sélectionnez la table PostGIS *lidar* et cliquez sur *Base de données -> Fenêtre SQL*
pour ouvrir un onglet permettant de lancer des requêtes SQL.

![alt text][count]
[count]: imgs/count.png "Count patchs"

Nous pouvons lancer les même requêtes que sous pgAdmin et visualiser ainsi les
mêmes résultats :

```bash
> SELECT COUNT(PA) FROM lidar;
110 246
```

```bash
> SELECT sum(pc_numpoints(pa)) from lidar;
110 245 034
```

## Affichage des points d'un patch

Pour afficher les points d'un patch :

```bash
with tmp as (
    select
        pc_explode(pa) as pts
    from lidar
    where id = 21761
)
select
    pts::geometry(pointz, 2154) as geom
    , pc_astext(pts) as content
from tmp;
```

Vous pouvez ensuite charger le résultat de la requête dans une nouvelle couche
du canvas. En zoomant sur le contenu :

![alt text][points]
[points]: imgs/points.png "Points"

## Algorithme de compression

Rappellons que lors d'une compression dimensionnelle, chaque dimension d'un
*pcpatch* possède un algorithme de compression spécifique déterminé au moment
de remplir la base. Nous pouvons obtenir les algorithmes utilisés grâce à la
commande suivante :

```bash
select json_array_elements(pc_summary(pa)::json->'dims') from lidar where id = 1;
```

![alt text][algo]
[algo]: imgs/algo.png "Algorithme de compression"

## Altitude moyenne d'un patch

Il existe plusieurs méthodes pour récupérer l'altitude moyenne d'un patch.

On peut soit utiliser la fonction *pc_summary* qui renvoie les statistiques
d'un patch (vue dans l'étape 1) :

```bash
with tmp as (
    select
        json_array_elements(pc_summary(pa)::json->'dims') as dims
    from lidar where id = 1
)
select
    dims->'stats'->'avg'
from tmp
where dims->>'name' = 'Z';
```

Soit la calculer en moyennant l'altitude de chacun des points d'un patch :

```bash
with tmp as (
    select
        pc_get(pc_explode(pa), 'z') as z
    from lidar
    where id = 1
)
select avg(z) from tmp;
```

Dans les deux cas, nous retombons sur une altitude d'environ 1205.01 mètres pour
le patch ayant l'id *1*.

## Altitude minimum/maximum de la couche

Afin de déterminer l'altitude minimum et maximum d'une couche complète, c'est à
dire sur l'ensemble des patchs, nous pouvons utiliser les fonctions
*pc_patchmin* et *pc_patchmax* :

```bash
select
    min(pc_patchmin(pa, 'z')) as min,
    max(pc_patchmax(pa, 'z')) as max
from lidar;
```

## Altitude du Puy De Dôme

L'altitude du Puy de Dôme est de 1465 mètres selon Wikipedia. Voyons si nous
pouvons retrouver la même valeur grâce aux données LIDAR.

Dans un premier temps, il faut déterminer notre zone de travail grâce à une
bounding box. Vous pouvez visualiser la zone choisie en chargeant le fichier
*puy.txt*. Notez que l'on travaille dans le système de projection Français
légal, soit Lambert-93 (appellé aussi EPSG:2154).

En utilisant le plugin *Open Layers plugin* disponible dans le menu *Web*, nous
pouvons charger des tuiles Open Street Map pour mieux visualiser la bounding
box utilisée.

![alt text][box]
[box]: imgs/box.png "Bounding box"

Les coordonnées de la bounding box sont :
- ( 696645.68;  6519545.26 )
- ( 696663.84; 6518613.49 )
- ( 697659.10; 6518611.79 )
- ( 697668.17; 6519546.03 )
- ( 696645.68; 6519545.26 )

Il faudra donc indiquer dans la requête SQL que l'on doit travailler seulement
sur les patchs de points contenu dans cette bounding box.

Notons aussi que les données du Puy de Dôme ont été chargées à partir de
fichiers LAS version 1.4, révision 6 :
http://www.asprs.org/wp-content/uploads/2010/12/LAS_1-4_R6.pdf.

![alt text][classif]
[classif]: imgs/classif.png "Classification"

Donc si nous souhaitons récupérer l'altitude du Puy de Dôme, il faudra
travailler uniquement sur les points représentant le sol (et pas la végétation,
les batiments, ...). Nous devrons donc trier les données en fonction de leur
classification.

Une fois que vous avez tous les éléments pour compléter la requête SQL suivante,
vous pouvez la lancer et comparer les résultats avec l'altitude réelle attendue.

```bash
with tmp as (
select
    pc_explode(pa) as pt
from lidar
where pc_intersects(pa,
    st_geomfromtext('polygon
        ((696645.68607813317794353 6519545.26375959813594818,
        696663.84967180131934583 6518613.49844292085617781,
        697659.1059435592032969 6518611.79729700554162264,
        697668.17463409807533026 6519546.03088010009378195,
        696645.68607813317794353 6519545.26375959813594818))',
        TODO_EPSG_CODE))
)
select
    round(pc_get(pt, 'TODO_DIMENSION')) as alt
from tmp
where pc_get(pt, 'Classification') = TODO_CLASSIFICATION_LEVEL
order by alt desc limit 1;
```

## Courbes de niveau

Complétez la requête ci-dessous afin de récupérer des courbes de niveau tous
les 10 mètres grâce à des enveloppes concaves :

```bash
select
    contour
    , st_exteriorring(
        st_concavehull(
            st_collect(d.geom),
            0.99
        )) as geom
from dome_points d
join generate_series(TODO_MAXIMUM_ALTITUDE, TODO_MINIMUM_ALTITUDE, TODO_STEP) as contour on contour = d.alt
group by contour;
```

Avec le fond de carte et en affichant les labels grâce à l'attribut *contour*
de la couche (pour avoir le niveau d'élévation affiché pour chaque enveloppe),
nous obtenons alors ceci :

![alt text][concave]
[concave]: imgs/concave.png "Enveloppes concaves"

De même avec des enveloppes convexes :

```bash
select
    contour
    , st_exteriorring(
        st_convexhull(
            st_collect(d.geom)
        )) as geom
from dome_points d
join generate_series(TODO_MAXIMUM_ALTITUDE, TODO_MINIMUM_ALTITUDE, TODO_STEP) as contour on contour = d.alt
group by contour;
```

![alt text][convex]
[convex]: imgs/convex.png "Enveloppes convexes"

On peut aussi utiliser une couche WMS pour visualiser les courbes de niveau sur
des orthophotographies. Pour cela, ajoutez une couche de type *WMS/WMTS* et
créez une nouvelle connexion avec l'URL *http://wms.craig.fr/ortho*
(pas d'authentification). Ensuite, sélectionnez par exemple
*site_puy_de_dome_2011* et cliquez sur le bouton *Ajouter*.

![alt text][wms]
[wms]: imgs/wms.png "Orthophotographies"
