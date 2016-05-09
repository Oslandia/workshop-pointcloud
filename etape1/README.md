# LAStools

Lors de cette première étape, nous allons manipuler des fichiers LAZ/LAS à
l'aide des outils fournis par LAStools.

Pour cela, rendez-vous dans le répertoire de travail de l'atelier etape1 :

```bash
> cd <WORKSHOP_DIRECTORY>/etape1
```

Ce répertoire contient entre autre un fichier LAS compressé : *sample.laz*.

## Récupération d'informations

L'outil **lasinfo** permet de récupérer des informations sur un fichier non
compressé *LAS* ou bien directement sur un fichier compressé *LAZ*.

Exécutez la commande suivante dans un terminal :

```bash
> lasinfo sample.laz
---------------------------------------------------------
  Header Summary
---------------------------------------------------------

  Version:                     1.2
  Source ID:                   0
  Reserved:                    1
  Project ID/GUID:             '00000000-0000-0000-0000-000000000000'
  System ID:                   ''
  Generating Software:         'TerraScan'
  File Creation Day/Year:      323/2013
  Header Byte Size             227
  Data Offset:                 229
  Header Padding:              2
  Number Var. Length Records:  None
  Point Data Format:           1
  Number of Point Records:     1344525
  Compressed:                  False
  Number of Points by Return:  1049320 201436 71313 18757 3699
  Scale Factor X Y Z:          0.01000000000000 0.01000000000000 0.01000000000000
  Offset X Y Z:                -0.00 -0.00 -0.00
  Min X Y Z:                   696749.70 6518749.99 1179.12
  Max X Y Z:                   697500.30 6519500.01 1547.86
  Spatial Reference:           None

---------------------------------------------------------
  Schema Summary
---------------------------------------------------------
  Point Format ID:             1
  Number of dimensions:        13
  Custom schema?:              false
  Size in bytes:               28

  Dimensions
---------------------------------------------------------
  'X'                            --  size: 32 offset: 0
  'Y'                            --  size: 32 offset: 4
  'Z'                            --  size: 32 offset: 8
  'Intensity'                    --  size: 16 offset: 12
  'Return Number'                --  size: 3 offset: 14
  'Number of Returns'            --  size: 3 offset: 14
  'Scan Direction'               --  size: 1 offset: 14
  'Flightline Edge'              --  size: 1 offset: 14
  'Classification'               --  size: 8 offset: 15
  'Scan Angle Rank'              --  size: 8 offset: 16
  'User Data'                    --  size: 8 offset: 17
  'Point Source ID'              --  size: 16 offset: 18
  'Time'                         --  size: 64 offset: 20

---------------------------------------------------------
  Point Inspection Summary
---------------------------------------------------------
  Header Point Count: 1344525
  Actual Point Count: 1344525

  Minimum and Maximum Attributes (min,max)
---------------------------------------------------------
  Min X, Y, Z:          696749.70, 6518749.99, 1179.12
  Max X, Y, Z:          697500.30, 6519500.01, 1547.86
  Bounding Box:         696749.70, 6518749.99, 697500.30, 6519500.01
  Time:                 62058236.055478, 62058617.780456
  Return Number:        1, 5
  Return Count:         1, 5
  Flightline Edge:      1, 1
  Intensity:            5, 44177
  Scan Direction Flag:  0, 0
  Scan Angle Rank:      63, 110
  Classification:       2, 4
  Point Source Id:      5, 6
  User Data:            1, 5
  Minimum Color (RGB):  0 0 0
  Maximum Color (RGB):  0 0 0

  Number of Points by Return
---------------------------------------------------------
        (1) 1049320     (2) 201436      (3) 71313       (4) 18757       (5) 3699

  Number of Returns by Pulse
---------------------------------------------------------
        (1) 847593      (2) 260179      (3) 157806      (4) 60381       (5) 18566

  Point Classifications
---------------------------------------------------------
        735106 Ground (2)
        609419 Medium Vegetation (4)
  -------------------------------------------------------
        0 withheld
        0 keypoint
        0 synthetic
  -------------------------------------------------------
```

On en retire notamment les informations suivantes :

  - la version du format LAS utilisé : 1.2
  - la date de création : 323/2013
  - le nombre de points : 1018103
  - le fait que la donnée est compressée avec laszip
  - les dimensions d'un point
  - des informations sur la position, l'altitude
  - ...

## Décompression

Un fichier *LAZ* peut être décompressé grâce à l'outil **las2las**.

Exécutez la commande suivante dans un terminal :

```bash
> las2las -i sample.laz -o sample.las
```

En utilisant l'outil **lasinfo** sur le fichier **sample.las**, on observe que
le fichier n'est plus compressé.

```bash
> lasinfo sample.las
...
Number of Point Records:     1018103
Compressed:                  False
Number of Points by Return:  683374 234643 78634 18231 3221
...
```

## Conversion en ASCII

Un fichier **LAS** est binaire et ne peut pas être lu en ouvrant un éditeur. Si
on souhaite récupérer les données en ASCII :

```bash
> las2txt -i sample.las -o sample.txt --parse xyzi --delimiter " "
```

Grâce à cela, le fichier sample.txt va contenir les points définis par :
  - x : position en x
  - y : position en y
  - z : altitude
  - i : intensité du retour

```bash
> head sample.txt
694506.68 6511999.95 1047.40 13
694500.69 6511999.11 1049.90 40
694502.85 6511999.24 1052.63 33
694501.44 6511999.11 1049.29 80
694503.33 6511999.20 1051.33 104
694504.84 6511999.26 1052.47 74
694505.83 6511999.27 1052.34 105
694506.48 6511999.26 1051.49 61
694504.40 6511999.06 1046.49 18
694508.06 6511999.32 1052.82 100
```
