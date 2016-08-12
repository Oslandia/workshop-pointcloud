# QGIS

During this fourth stage, we are going to use QGIS as a visualization tool.
Moreover, we will run more complex SQL queries in order to get various
information such as the Puy-De-Dôme altitude.

## Add a PostGIS layer

Firstly, start QGIS and add a PostGIS layer by doing
*Layer -> Add Layer -> Add PostGIS Layer*. Then, you can create a new connection
by clicking on the *New* button. Finally, you just have to fill the same
information as those used during the previous step with pgAdmin.

Once you have clicked on the *OK* button, you can establish the connection with
the remote database by clicking on *Connect*. Then you are able to select the
desired layer and add it in the QGIS canvas thanks to the *Add* button.

![alt text][conn]
[conn]: imgs/conn.png "Connection"

Data should be loading within the QGIS canvas and you should see something like
this:

![alt text][data]
[data]: imgs/data.png "Data"

## LIDAR data

Only wanted layers can be displayed thanks to the checkbox in front of each
layer in the QGIS layer tree.

![alt text][tree]
[tree]: imgs/tree.png "Layer Tree"

If the *lidar* layer is the only one displayed, we can clearly see bounds of
patches previously built by the *chipper* filter of PDAL:

![alt text][patchs]
[patchs]: imgs/pcpatch.png "Patches"

## Database manager

In this chapter, we are going to play with the *Database Manager* of QGIS which
allows the user to write and run SQL queries like the *Query Tool* previously
used within pgAdmin.

You can open it by clicking on *Database -> DB Manager -> DB Manager*. Then,
after selecting the PostGIS *lidar* table, click on *Database -> SQL window* to
open a new tab allowing you to write and run SQL queries.

![alt text][count]
[count]: imgs/count.png "Count patches"

Through the SQL editor, we are able to run the same queries than those
previously seen with pgAdmin:

```sql
> SELECT COUNT(PA) FROM lidar;
110 246
```

```sql
> SELECT sum(pc_numpoints(pa)) from lidar;
110 245 034
```

## Display a patch content

In order to retrieve points contained by the patch with the id *21761*:

```sql
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

Then you can load these points as a new layer in the QGIS canvas:

![alt text][points]
[points]: imgs/points.png "Points"

You can use QGIS styling capabilities to display the Z value of the points. Go to the styling window of the generated layer, and setup a graduated style using as an expression the z value of the geometry : `z($geometry)`.

Now we do the same with the intensity value. We use the `PC_Get(pt pcpoint, dimname text)` function to get the intensity value in our query. Run and style it using a graduated style on the intensity value.

```sql
with tmp as (
    select
        pc_explode(pa) as pts
    from lidar
    where id = 21761
)
select
    row_number() over () as id
    , pts::geometry(pointz, 2154) as geom
    , PC_Get(pts, 'Intensity') as intensity
    -- note that once the point is converted to a geometry we
    -- can use any PostGIS function, like getting the z value
    , ST_Z(pts::geometry(pointz, 2154)) as z
from tmp;
```

Some points show much higher intensity than the others. Guess why ?

To be able to answer this question, we need some context information. Install the QuickMapServices QGIS plugin and load the contributed Bing Map Satellite background layer : 

- Open Plugins -> Manage and install plugins
- Search for QuickMapServices
- Install Plugin
- Go to Web -> QuickMapServices -> Settings -> More Services -> Get contributed pack and save
- Go to Web -> QuickMapServices -> Bing -> Bing Satellites

Now answer the following questions :
- Why some points have higher intensity ?
- Why was the white car not detected ?
- Try the same query on some other patches along the road

We can have a better view with the WMS layer provided by CRAIG ( 1px = 10 cm). 
To do that, you just have to add a *WMS* layer and create a new connection with
*http://wms.craig.fr/ortho* (does not imply authentification). Then, after
selecting *site_puy_de_dome_2011*, click on *Add* button.

## Compression algorithm

Just a quick reminder that with a dimensional compression, each dimension of
a *pcpatch* has its own compression algorithm, dynamically determined during the
filling of the database. We can determined which algorithm is currently used
for each of the dimensions thanks to the next query:

```sql
select json_array_elements(pc_summary(pa)::json->'dims') from lidar where id = 1;
```

![alt text][algo]
[algo]: imgs/algo.png "Compression algorithm"

## Average altitude of a patch

In fact, there is at least 2 ways to retrieve the average altitude of a patch.

Either we use the *pc_summary* function:

```sql
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

or we compute it:

```sql
with tmp as (
    select
        pc_get(pc_explode(pa), 'z') as z
    from lidar
    where id = 1
)
select avg(z) from tmp;
```

In these two cases, we have a mean altitude of about 1205.01 meters for the
patch *1*.

## Minimum and maximum altitude over the layer

In order to determine the minimum and maximum values for the altitude over all
patches of the layer, we can use the *pc_patchmin* and *pc_patchmax* functions:

```sql
select
    min(pc_patchmin(pa, 'z')) as min,
    max(pc_patchmax(pa, 'z')) as max
from lidar;
```

## Puy-De-Dôme altitude

The altitude of the Puy-De-Dôme is about 1465 meters according to Wikipedia.
Lets try to retrieve the same values thanks to our LIDAR data.

In a first stage, we have to determine the Puy-De-Dôme area thanks to a
bounding box. This bounding box can be visualized by loading the file named
*puy.txt*. Note that we are working with the French projection system
Lambert-93, also known as EPSG:2154.

We can use the same QuickMapServics plugin to load a map and have a better look on our working area, or the WMS service.

![alt text][box]
[box]: imgs/box.png "Bounding box"

Bounding box coordinates are:
- ( 696645.68;  6519545.26 )
- ( 696663.84; 6518613.49 )
- ( 697659.10; 6518611.79 )
- ( 697668.17; 6519546.03 )
- ( 696645.68; 6519545.26 )

So, we have to indicate in our SQL query that we only want to work with patches
contained within this box.

Moreover, note that *Puy-De-Dôme* LIDAR data has been loaded from files having
a LAS format with version 1.4, revision 6:
http://www.asprs.org/wp-content/uploads/2010/12/LAS_1-4_R6.pdf.

![alt text][classif]
[classif]: imgs/classif.png "Classification"

So, if we want to get the altitude, we must concentrate on points representing
the ground (and not buildings, vegetation, ...). Thus, we have to sort the data
according to the classification field.

Once you have found all the necessary information to fullfill the below SQL
query, you can run it and compare the thus obtained altitude with the real
one.

```sql
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
        "TODO_EPSG_CODE"))
)
select
    round(pc_get(pt, 'TODO_DIMENSION')) as alt
from tmp
where pc_get(pt, 'Classification') = TODO_CLASSIFICATION_LEVEL
order by alt desc limit 1;
```

## Level curves

Fullfill the below query to retrieve the level of curves represented by concave
hull:

```sql
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

By displaying the map and labels for the *contour* field, we have:

![alt text][concave]
[concave]: imgs/concave.png "Concave Hull"

The same thing can be done with convex hull:

```sql
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
[convex]: imgs/convex.png "Convex Hull"


With aerial imagery : 

![alt text][wms]
[wms]: imgs/wms.png "Orthophotos"
