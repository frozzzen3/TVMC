# **TVMC: Time-Varying Mesh Compression Using Volume-Tracked Reference Meshes**

Guodong Chen, Filip Hácha, Libor Váša, Mallesham Dasari

![alt text](https://github.com/frozzzen3/TVMC/blob/main/images/TVMC-workflow.png?raw=true)

This repository contains the official authors implementation associated with the paper **"TVMC: Time-Varying Mesh Compression Using Volume-Tracked Reference Meshes"**, which can be found [here] (to be added), accepted by [2025 ACM MMSys](https://2025.acmmmsys.org/).

## Step-by-Step Tutorial

This tutorial demonstrates the complete pipeline using the `basketball player` dataset from [TDMD](https://multimedia.tencent.com/resources/tdmd).

## Step 1: As-Rigid-As-Possible (ARAP) Volume Tracking

ARAP volume tracking is written in C# and .NET 7.0

Navigate to the root directory:

```
cd ./arap-volume-tracking
```

Build the project:

```
dotnet build -c release
```

Run the tracking process:

```
dotnet ./bin/Client.dll ./config/max/config-basketball-max.xml
```

Volume tracking results are saved in the `<outDir>` folder:

- `.xyz` files: coordinates of volume centers
- `.txt` files: transformations of centers between frames

### Global Optimization (Optional but Recommended)

Global optimization refines volume centers by removing abnormal volume centers and adjusting positions for the remains to reduce distortions.

```
dotnet ./bin/Client.dll ./config/impr/config-basketball-impr.xml
```

Results are stored in `<outDir>/impr`.

Additional time-varying mesh sequences are available in `./arap-volume-tracking/data`. Configuration files are in `./arap-volume-tracking/config`. Different tracking modes (`./iir`, `./impr`, `./max`) use distinct configurations. More details [here](https://github.com/frozzzen3/TVMC/blob/main/arap-volume-tracking/README.md).

To run ARAP volume tracking on a custom dataset:

```
dotnet ./bin/client.dll <config_file.xml>
```

## Step 2: Generate Reference Centers Using Multi-Dimensional Scaling (MDS)

Navigate to TVMC root:

```
cd ./TVMC
```

Run the MDS script:

```
python ./get_reference_center.py --dataset basketball_player --num_frames 10 --num_centers 1995 --centers_dir ../arap-volume-tracking/data/basketball-output-max-2000/impr
```

The number of centers (`--num_centers`) must match the global optimization results. Output is stored in `./arap-volume-tracking/data/basketball-output-max-2000/impr/reference/reference_centers_aligned.xyz`.

If the number of volume centers is large, experiment with different `random_state` values for better results.

## Step 3: Compute Transformation Dual Quaternions

Navigate to TVMC root:

```
cd ./TVMC
```

Then, we compute the transformations for each center, mapping their original positions to the reference space, along with their inverses. These transformations are then used to deform the mesh surface based on the movement of volume centers.

```
python ./get_transformation.py --dataset basketball_player --num_frames 10 --num_centers 1995 --centers_dir ../arap-volume-tracking/data/basketball-output-max-2000/impr --firstIndex 11 --lastIndex 20
```

## Step 4: Create Volume-Tracked, Self-Contact-Free Reference Mesh

Navigate to the `tvm-editing` directory and build:

```
cd ./tvm-editing
dotnet build TVMEditor.sln --configuration Release --no-incremental
```

Run the mesh deformation:

```
TVMEditor.Test/bin/Release/net5.0/TVMEditor.Test.exe basketball 1 11 20 "./TVMEditor.Test/bin/Release/net5.0/Data/basketball_player_1995/" "./TVMEditor.Test/bin/Release/net5.0/output/basketball_player_1995/"
```

for Linux:

```
TVMEditor.Test/bin/Release/net5.0/TVMEditor.Test basketball 1 11 20 "./TVMEditor.Test/bin/Release/net5.0/Data/basketball_player_1995/" "./TVMEditor.Test/bin/Release/net5.0/output/basketball_player_1995/"
```



Navigate to TVMC root again:

```
cd ./TVMC
```

Extract the reference mesh:

```
python ./extract_reference_mesh.py --dataset basketball_player --num_frames 10 --num_centers 1995 --inputDir ../tvm-editing/TVMEditor.Test/bin/Release/net5.0/output/basketball_player_1995/output/ --outputDir ../tvm-editing/TVMEditor.Test/bin/Release/net5.0/Data/basketball_player_1995/reference_mesh/ --firstIndex 11 --lastIndex 20
```

## Step 5: Deform Reference Mesh to Each Mesh in the Group

Navigate to the `tvm-editing` directory,

```
cd ./tvm-editing
```

Then run:

```
TVMEditor.Test/bin/Release/net5.0/TVMEditor.Test.exe basketball 2 11 20 "./TVMEditor.Test/bin/Release/net5.0/Data/basketball_player_1995" "./TVMEditor.Test/bin/Release/net5.0/output/basketball_player_1995/"
```

For Linux:

```
TVMEditor.Test/bin/Release/net5.0/TVMEditor.Test basketball 2 11 20 "./TVMEditor.Test/bin/Release/net5.0/Data/basketball_player_1995" "./TVMEditor.Test/bin/Release/net5.0/output/basketball_player_1995/"
```



## Step 6: Compute Displacement Fields

Navigate to TVMC root again:

```
cd ./TVMC
```

```
python ./get_displacements.py --dataset basketball_player --num_frames 10 --num_centers 1995 --target_mesh_path ../arap-volume-tracking/data/basketball_player --firstIndex 11 --lastIndex 20
```

The displacement fields are stored as `.ply` files. For compression, Draco is used to encode both the reference mesh and displacements.



Tips: So far, we've got everything we need for a group of time-varying mesh compression (A self-contact-free reference mesh and displacement fields). You can use any other compression methods to deal with them. For example, you may use video coding to compress displacements to get even better compression performance.

## Step 7: Compression and Evaluation

Clone and build Draco:

```
git clone https://github.com/google/draco.git
cd ./draco
mkdir build
cd build
```

On Windows:

```
cmake ../ -G "Visual Studio 17 2022" -A x64
cmake --build . --config Release
```

On Linux:

```
cmake ../
make
```

On Mac OS X, run the following command to generate Xcode projects:

```
$ cmake ../ -G Xcode
```

Draco paths:

- Encoder: `./draco/build/Release/draco_encoder.exe`
- Decoder: `./draco/build/Release/draco_decoder.exe`

Navigate to TVMC root again:

```
cd ./TVMC
```

Run the evaluation:

```
python ./evaluation.py --dataset basketball_player --num_frames 10 --num_centers 1995 --firstIndex 11 --lastIndex 20 --fileNamePrefix basketball_player_fr0 --encoderPath ../draco/build/Release/draco_encoder.exe --decoderPath ../draco/build/Release/draco_decoder.exe --qp 10 --outputPath ./basketball_player_outputs
```
