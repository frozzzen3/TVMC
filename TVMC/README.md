# **TVMC: Time-Varying Mesh Compression Using Volume-Tracked Reference Meshes**

I'll use `Dancer` dataset from [TDMD](https://multimedia.tencent.com/resources/tdmd) to show the whole pipeline.

Step 1: As-rigid-as-possible Volume tracking

go to the root `cd ./arap-volume-tracking `

build `dotnet build -c release`, The build application is in `./bin` folder.

`dotnet ./bin/client.dll ./config/max/config-dancer-max.xml`

Now, you can find volume tracking results in the `<outDir>` folder.

`.xyz` files represent the coordinates of each centers 

`.xyz` files represent the coordinates of each centers 

Time-varying mesh sequences are stored in `./arap-volume-tracking/data`

configuration files can be found in `./arap-volume-tracking/config`

You may be curious about why there are three folders, actually `./iir` `./impr` `./max` represent different configuration files for three tracking modes, please find more details and examples [here](https://github.com/frozzzen3/TVMC/blob/main/arap-volume-tracking/README.md).

After setting configurations, run

`dotnet ./bin/client.dll <config_file.xml>` 

(e.g., `dotnet ./bin/client.dll ./config/max/config-dancer-max.xml`)
