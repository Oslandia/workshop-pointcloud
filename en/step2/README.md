# PDAL pipeline

For this second step, we are going to use PDAL in order to learn how to build
a pipeline.

The online documentation is here : http://www.pdal.io/

Change the current working directory for the step2 :

```bash
> cd <WORKSHOP_DIRECTORY>/step2
```

This directory contains:
  - 3 LAS files *sample1.las*, *sample2.las* and *sample3.las*
  - 2 pipes *pipe_merge.json* and *pipe_pg.json*

## Merge multiple files

The first step is to write a file in JSON to describe the pipeline. In our case,
we want to merge multiple LAS files, then write a new LAS file named
*merged.las*. So, we'll need two elements:
  - a filter to merge N files
  - a writer for the LAS output file

If we want to merge *sample1.las* and *sample2.las*, the pipeline file looks
like:

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

Modify the content of *pipe_merge.json* to merge *sample1.las*, *sample2.las*
and *sample3.las* files. Then run the below command line:

```bash
> pdal pipeline pipe_merge.json
```

A *merged.las* file is created. You can use the **lasinfo** tool to check if
the number of points  is consitent with expectations.

An other way to merge multiple files with PDAL is to use the **pdal merge**
command:

```bash
> pdal merge sample1.las sample2.las sample3.las merged2.las
```

## pgpointcloud writer

Now that we have created a single LAS file, we want to build a pipeline
able to fill a database of patches with the pgpointcloud extension.

To build patches, we have to use the chipper filter. Thus, the full
pipeline looks like:

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

Replace the field "dbname=XXXXXXXXXXXXXXXXXXXX" within the *pipe_pg.json* file
by your DATABASE_NAME and run the next command:

```bash
> createdb DATABASE_NAME
> psql -d DATABASE_NAME -f schema.sql
> pdal pipeline pipe_pg.json
```

Then you may connect to the database and get the list of relations:

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

If you want to count the number of patches and the number of points:

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

Note that the number of points is the same than the one get by the **lasinfo**
tool on the *merged.las* file:

```bash
> lasinfo merged.las
  ...
  Number Var. Length Records:  None
  Point Data Format:           3
  Number of Point Records:     1018103
  Compressed:                  False
  ...
```

You can also check if the number of points per patch is well 400 as mentioned in
the *pipe_pg.json* file:

```bash
DATABASE_NAME=# SELECT pc_numpoints(pa) from patches limit 1;
   sum
---------
 400
(1 row)
```
