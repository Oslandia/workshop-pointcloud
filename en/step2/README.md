# PDAL pipeline

For this second step, we are going to use PDAL in order to learn how to build
a pipeline.

The online documentation is here : http://www.pdal.io/

Change the current working directory for the step2:

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
      "connection":"host=hekla.oslandia.net port=5433 dbname=foss4g user=foss4g password=XXXXXXXX",
      "table":"xxx_patches"
    }
  ]
}
```

This example loads the `merged.las` file into a PostgreSQL database with PgPointCloud extension activated. Since we use a remote server here and share the bandwidth, we will not load the `merged.las` file, but a small subset ( the full dataset has already been loaded anyway for later use).

- Use the commands from last step to split `merged.las` into files of 25000 points
- Replace the password=XXXXXX in the `pipe_pg.json` file with the one you have been given
- Replace the destination table name with your name in it ( use a trigram prefix like `vpi_patches` ).
- Replace the LAS data filename to load only the first of the subset files from the split command

Then run the pdal import command below. 

```bash
pdal pipeline pipe_pg.json
```

Then you may connect to the database with psql or pgadmin and get the list of relations. You should see something similar to the following using psql.

In order to ease the connection to the database, you can save the password for this connection. Once you have a `.pgpass` file, later connections to the database should not ask for a password. 

```bash
echo "hekla.oslandia.net:5433:foss4g:foss4g:XXXXXXXXXXX" >> ~/.pgpass
```

```bash
> psql -h hekla.oslandia.net -p 5433 -U foss4g -d foss4g
psql (9.5.1)
Type "help" for help.

foss4g=# \d
                 List of relations
 Schema |        Name        |   Type   |   Owner
--------+--------------------+----------+-----------
 public | geography_columns  | view     | oslandia
 public | geometry_columns   | view     | oslandia
 public | vpi_patches        | table    | oslandia
 public | vpi_patches_id_seq | sequence | oslandia
 public | pointcloud_columns | view     | oslandia
 public | pointcloud_formats | table    | oslandia
 public | raster_columns     | view     | oslandia
 public | raster_overviews   | view     | oslandia
 public | spatial_ref_sys    | table    | oslandia
(9 rows)
```

If you want to count the number of patches and the number of points. Use the PgAdmin SQL window or the psql command line tool to execute the query.

```bash
foss4g=# SELECT count(pa) FROM patches;
 count
-------
  2546
(1 row)
```

```bash
foss4g=# SELECT sum(pc_numpoints(pa)) from patches;
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

You can also check if the number of points per patch is 400 as mentioned in
the *pipe_pg.json* file:

```bash
foss4g=# SELECT pc_numpoints(pa) from patches limit 1;
   sum
---------
 400
(1 row)
```
