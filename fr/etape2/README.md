# Pipeline PDAL

Lors de cette deuxième étape, nous allons apprendre à utiliser PDAL en ligne
de commande et notamment apprendre à construire une chaine de traitement.

Pour cela, rendez-vous dans le répertoire de travail de l'atelier etape2 :

```bash
> cd <WORKSHOP_DIRECTORY>/etape2
```

Ce répertoire contient:
  - 3 fichiers LAS *sample1.las*, *sample2.las* et *sample3.las*
  - 2 pipes *pipe_merge.json* et *pipe_pg.json*

La documentation en ligne de PDAL est ici : http://www.pdal.io/

## Fusion de fichiers

La première étape est d'écrire un fichier JSON décrivant la chaine de
traitement. Dans notre cas, nous voulons fusionner plusieurs fichiers LAS
en un seul nommé *merged.las*. Nous avons donc besoin de 2 éléments :
  - un filtre capable de merger N fichiers
  - un *writer* permettant d'écrire un nouveau fichier LAS

Si nous voulons merger les fichiers *sample1.las* et *sample2.las*, la
chaine de traitement doit ressembler à celle çi-dessous:

```bash
{
  "pipeline":[
    {
      "filename": "sample1.las",
      "tag": "sample1"
    },
    {
      "filename": "sample2.las",
      "tag": "sample2"
    },
    {
      "type": "filters.merge",
      "inputs": ["sample1", "sample2"]
    },
    {
      "type": "writers.las",
      "filename": "merged.las"
    }
  ]
}
```

Modifier le contenu du fichier *pipe_merge.json* afin de fusionner les 3 fichiers
*sample1.las*, *sample2.las* et *sample3.las*. Ensuite, lancez la commande
çi-dessous:

```bash
> pdal pipeline pipe_merge.json
```

Un fichier *merged.las* est créé. Vous pouvez utiliser la commande **lasinfo**
pour vérifier si le nombre de points est bien similaire aux attentes.

Un autre moyen de fusionner des fichiers avec PDAL est d'utiliser la
commande **pdal merge** :

```bash
> pdal merge sample1.las sample2.las sample3.las merged2.las
```

## pgpointcloud writer

Maintenant que nous avons un seul fichier LAS, nous voulons construire une
chaine de traitement capable de remplir une base de données avec l'extension
pgpointcloud.

Pour construire des patchs de points, nous allons utiliser le filtre *chipper*.
La chaine de traitement va alors ressembler à :

```bash
{
  "pipeline":[
    {
      "type":"readers.las",
      "filename":"merged.las"
    },
    {
      "type":"filters.chipper",
      "capacity":400
    },
    {
      "type":"writers.pgpointcloud",
      "connection":"dbname=XXXXXXXXXXXXXXXXXXXX user=postgres",
      "table":"patches"
    }
  ]
}
```

Remplacez le champ "dbname=XXXXXXXXXXXXXXXXXXXX" dans le fichier *pipe_pg.json*
avec le nom de votre base de données puis lancez la commande suivante :

```bash
> createdb DATABASE_NAME
> psql -d DATABASE_NAME -f schema.sql
> pdal pipeline pipe_pg.json
```

Vous pouvez ensuite vous connecter à la base et récupérer par exemple la liste
des relations :

```bash
> psql DATABASE_NAME
psql (9.5.1)
Type "help" for help.

DATABASE_NAME=# \d
                 List of relations
 Schema |        Name        |   Type   |   Owner
--------+--------------------+----------+-----------
 public | geography_columns  | view     | oslandia
 public | geometry_columns   | view     | oslandia
 public | patches            | table    | oslandia
 public | patches_id_seq     | sequence | oslandia
 public | pointcloud_columns | view     | oslandia
 public | pointcloud_formats | table    | oslandia
 public | raster_columns     | view     | oslandia
 public | raster_overviews   | view     | oslandia
 public | spatial_ref_sys    | table    | oslandia
(9 rows)
```

Si vous souhaitez compter le nombre de patchs ou bien le nombre de points
présent en base :

```bash
DATABASE_NAME=# SELECT count(pa) FROM patches;
 count
-------
  2546
(1 row)
```

```bash
DATABASE_NAME=# SELECT sum(pc_numpoints(pa)) from patches;
   sum
---------
 1018103
(1 row)
```

Notons que le nombre de points obtenu est le même que celui retourné par
**lasinfo** sur le fichier *merged.las* :

```bash
> lasinfo merged.las
  ...
  Number Var. Length Records:  None
  Point Data Format:           3
  Number of Point Records:     1018103
  Compressed:                  False
  ...
```

Vous pouvez aussi vérifier le nombre de points présent dans un patch pour
vérifier si cela concorde avec celui indiqué dans la chaine de traitement
décrite dans le fichier *pipe_pg.json* :

```bash
DATABASE_NAME=# SELECT pc_numpoints(pa) from patches limit 1;
   sum
---------
 400
(1 row)
```
