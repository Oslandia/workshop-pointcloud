# libLAS

Our goal at this initial stage is to work with LAZ/LAS files thanks to the
command line tools provided by libLAS.

Change the current working directory for the step1 :

```bash
> cd <WORKSHOP_DIRECTORY>/step1
```

This directory contains a LAZ compressed file: *sample.laz*.

## Retrieve information

The **lasinfo** tool allows to retrieve information on a non compressed *LAS*
file or on a compressed LAZ file.

Run the next command:

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
  Data Offset:                 327
  Header Padding:              0
  Number Var. Length Records:  1
  Point Data Format:           1
  Number of Point Records:     1018103
  Compressed:                  True
  Compression Info:            LASzip Version 2.2r0 c2 50000: POINT10 2 GPSTIME11 2
  Number of Points by Return:  683374 234643 78634 18231 3221
  Scale Factor X Y Z:          0.01000000000000 0.01000000000000 0.01000000000000
  Offset X Y Z:                -0.00 -0.00 -0.00
  Min X Y Z:                   694500.38 6511250.01 1030.25
  Max X Y Z:                   695250.36 6512000.00 1788.35
  Spatial Reference:           None

  ---------------------------------------------------------
  VLR Summary
  ---------------------------------------------------------
    User: 'laszip encoded' - Description: 'http://laszip.org'
    ID: 22204 Length: 46 Total Size: 100
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
  Header Point Count: 1018103
  Actual Point Count: 1018103

  Minimum and Maximum Attributes (min,max)
  ---------------------------------------------------------
  Min X, Y, Z:    694500.38, 6511250.01, 1030.25
  Max X, Y, Z:    695250.36, 6512000.00, 1788.35
  Bounding Box:   694500.38, 6511250.01, 695250.36, 6512000.00
  Time:     62057103.925216, 62057316.386215
  Return Number:  1, 5
  Return Count:   1, 5
  Flightline Edge:  1, 1
  Intensity:    8, 541
  Scan Direction Flag:  0, 0
  Scan Angle Rank:  67, 118
  Classification: 2, 4
  Point Source Id:  2, 3
  User Data:    3, 5
  Minimum Color (RGB):  0 0 0
  Maximum Color (RGB):  0 0 0

  Number of Points by Return
  ---------------------------------------------------------
  (1) 683374  (2) 234643  (3) 78634 (4) 18231 (5) 3221

  Number of Returns by Pulse
  ---------------------------------------------------------
  (1) 447975  (2) 311939  (3) 181674  (4) 60317 (5) 16198

  Point Classifications
  ---------------------------------------------------------
  364264 Ground (2)
  653839 Medium Vegetation (4)
  -------------------------------------------------------
    0 withheld
    0 keypoint
    0 synthetic
  -------------------------------------------------------
```

Thanks to the **lasinfo** output, we have:

  - the version of the LAS format currently used: 1.2
  - the creation date: 323/2013
  - the number of points: 1018103
  - the kind of compression applied to the data
  - dimensions representing a point
  - various data on position, altitude, ...
  - ...

## Decompression

A LAZ file can be decompressed thanks to the **las2las** tool.

Run the next command:

```bash
> las2las -i sample.laz -o sample.las
```

By using the **lasinfo** tool on *sample.las*, we note that no compression
is currently applied unlike the tests previously done.

```bash
> lasinfo sample.las
...
Number of Point Records:     1018103
Compressed:                  False
Number of Points by Return:  683374 234643 78634 18231 3221
...
```

## ASCII conversion

A **LAS** file contains binary data, so it can't be read by a text editor. Thus,
if we want to retrieve some data in a human readable format, we have to use the
**las2txt** tool:

```bash
> las2txt -i sample.las -o sample.txt --parse xyzi --delimiter " "
```

Thanks to the previous command line, the *sample.txt* file is going to contain
points defined according to the next dimensions:
  - x : x position
  - y : y position
  - z : altitude
  - i : intensity

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

## Split

Thanks to the **las2las** tool, we can split a simple file in multiple files.
Either the split is done according to the number of points, or according a
size in MB.

To do that, we have to use the *--split-pts* argument.

```bash
> las2las --split-pts 509051 sample.laz
```

After running the command above, three files are created:
*output-1.las*, *output-2.las*, *output-3.las*.

Examine why thanks to the **lasinfo** command.
