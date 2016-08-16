# pgpointcloud et pgAdmin

Pour cette troisième étape, nous allons utiliser pgAdmin pour visualiser la base
*foss4g*. Nous commencerons aussi à lancer quelques requêtes SQL simples en
utilisant des fonctions pointcloud.

## Connexion à la base

Dans un premier temps, lancez pgAdmin et connectez vous à la base *foss4g* en
vous rendant dans *Fichier -> Ajouter un serveur*. Ci dessous les informations
de connexion :
  - IP : 37.187.164.233
  - Port : 5433
  - Base : foss4g
  - User : foss4g
  - Password : donné durant l'atelier

## Navigateur d'objets

Grâce au *Navigateur d'objets*, nous pouvons obtenir de nombreuses informations
concernant la base *foss4g* :
  - le nombre de tables ainsi que leurs noms
  - inspecter le contenu des tables
  - la liste des extensions
  - les fonctions disponibles
  - ...

![alt text][nav]
[nav]: imgs/nav.png "Navigateur d'objets"

Concernant par exemple la table *lidar*, on peut voir qu'elle possède deux
colonnes :
  - *id* de type entier
  - *pa* de type pcpatch : on retrouve ici les patchs pgpointcloud!

![alt text][pcpatch]
[pcpatch]: imgs/pcpatch.png "Table lidar"

## Requêtes SQL

Rendez vous dans l'éditeur de requêtes *Outils -> Editeur de requêtes*. Cet
outil permet de lancer des requêtes SQL.

![alt text][sql]
[sql]: imgs/sql.png "Editeur de requêtes"

Dans un premier temps, nous pouvons déterminer le nombre de patchs contenu dans
la table *lidar* :

```bash
> SELECT count(pa) FROM lidar;
110 246
```

Sachant, que nous avons indiqué au filtre *chipper* de PDAL d'avoir des patchs
de 1000 points environs, on peut estimer le nombre de points total à environ
**110,246 millions**.

L'extension *pointcloud* fournis de nombreuses fonctions préfixées par *pc_*.

![alt text][fct]
[fct]: imgs/fct.png "Fonctions pointcloud"

Nous pouvons obtenir le nombre exact de points grâce à la fonction pointcloud
*pc_numpoints* :

```bash
> SELECT sum(pc_numpoints(pa)) from lidar;
110 245 034
```

Nous pouvons aussi étudier le contenu d'un patch...

```bash
> SELECT pc_astext(pc_explode(pa)) FROM lidar LIMIT 1;
```

et obtenir un résumé (nombre de points, statistique, ...) :

```bash
> SELECT pc_summary(pa) FROM lidar LIMIT 1;
```
