# Activate Conda environment
conda activate open3d

# Step 1: ARAP Volume Tracking
cd C:\app\arap-volume-tracking
dotnet .\bin\client.dll .\config\max\config-basketball-max.xml
dotnet .\bin\client.dll .\config\impr\config-basketball-impr.xml

# Step 2: Generate Reference Centers
cd C:\app\TVMC
python get_reference_center.py --dataset basketball_player --num_frames 10 --num_centers 1995 --centers_dir ..\arap-volume-tracking\data\basketball-output-max-2000\impr

# Step 3: Compute Transformations
python get_transformation.py --dataset basketball_player --num_frames 10 --num_centers 1995 --centers_dir ..\arap-volume-tracking\data\basketball-output-max-2000\impr --firstIndex 11 --lastIndex 20

# Step 4: Mesh Processing
cd C:\app\tvm-editing
.\TVMEditor.Test\bin\Release\net5.0\TVMEditor.Test.exe basketball 1 11 20 "C:\app\tvm-editing\TVMEditor.Test\bin\Release\net5.0\Data\basketball_player_1995\" "C:\app\tvm-editing\TVMEditor.Test\bin\Release\net5.0\output\basketball_player_1995\"

# Step 5: Extract Reference Mesh
cd C:\app\TVMC
python extract_reference_mesh.py --dataset basketball_player --num_frames 10 --num_centers 1995 --inputDir ..\tvm-editing\TVMEditor.Test\bin\Release\net5.0\output\basketball_player_1995\output\ --outputDir ..\tvm-editing\TVMEditor.Test\bin\Release\net5.0\Data\basketball_player_1995\reference_mesh\ --firstIndex 11 --lastIndex 20

# Step 6: Compute Displacement Fields
python get_displacements.py --dataset basketball_player --num_frames 10 --num_centers 1995 --target_mesh_path ..\arap-volume-tracking\data\basketball_player --firstIndex 11 --lastIndex 20

# Step 7: Compression and Evaluation
python evaluation.py --dataset basketball_player --num_frames 10 --num_centers 1995 --firstIndex 11 --lastIndex 20 --fileNamePrefix basketball_player_fr0 --encoderPath ..\draco\build\Release\draco_encoder.exe --decoderPath ..\draco\build\Release\draco_decoder.exe --qp 10 --outputPath .\basketball_player_outputs
