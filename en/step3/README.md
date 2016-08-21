# pgpointcloud and pgAdmin

For this third step, we are going to use pgAdmin to explore the database named
*foss4g*. Then, we will begin to run some SQL queries with some functions coming
from the pgpointcloud extension.

## Database connection

Firstly, you have to start pgAdmin. Then, connect to the *foss4g* database by
clicking on *File -> Add Server...*. See below for detailed information
required to establish the connection:
  - Host : hekla.oslandia.net
  - Port : 5433
  - Base : foss4g
  - User : foss4g
  - Password : ...

## Object Browser

Thanks to the *Object Browser*, we are able to obtain plenty of information
about the *foss4g* database:
  - the number of tables as well as their names
  - inspect the content of tables
  - the list of extensions currently loaded
  - available functions
  - ...

![alt text][nav]
[nav]: imgs/nav.png "Object Browser"

For the *lidar* table, we can see that there is two columns:
  - *id* which is an integer field
  - *pa* which is a pcpatch field: we retrieve here the pgpointcloud pacthes!

![alt text][pcpatch]
[pcpatch]: imgs/pcpatch.png "lidar table"

## SQL Queries

Go to the SQL queries editor *Tools -> Query Tool*. This tool allows you to write
and run SQL queries.

![alt text][sql]
[sql]: imgs/sql.png "Query Tool"

Firstly, we can retrieve the number of patches within the *lidar* table:

```bash
> SELECT count(pa) FROM lidar;
110 246
```

Considering that we have indicated to the *chipper* filter of PDAL to build
pacthes of 1000 points, we are able to approximate the total number of points
to **110,246 millions**.

The *pgpointcloud* extension provides plenty of functions named *pc_XXXXXX*.

![alt text][fct]
[fct]: imgs/fct.png "Pointcloud functions"

Thanks to the *pc_numpoints* function, we can retrieve the exact number of
points within the lidar table:

```bash
> SELECT sum(pc_numpoints(pa)) from lidar;
110 245 034
```

Moreover, we can also study the content of a patch:

```bash
> SELECT pc_astext(pc_explode(pa)) FROM lidar LIMIT 1;
```

and get a summary of it:

```bash
> SELECT pc_summary(pa) FROM lidar LIMIT 1;
```
