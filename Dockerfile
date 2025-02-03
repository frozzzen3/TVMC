# Use Windows Server Core as base
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set working directory
WORKDIR C:\\app


# Install Visual Studio 2022 Build Tools, Python, and Git
RUN choco install visualstudio2022-buildtools --confirm \
    && choco install git python miniconda cmake --confirm

# Clone Draco repository
RUN git clone https://github.com/google/draco.git C:\app\draco \
    && cd C:\app\draco \
    && mkdir build && cd build \
    && cmake .. -G "Visual Studio 17 2022" -A x64 \
    && cmake --build . --config Release

# Clone TVMC project
RUN git clone https://github.com/frozzzen3/TVMC.git C:\app\TVMC

# Copy project files
COPY . C:\app

# Set up Conda and install Python dependencies from environment.yml
RUN conda env create -f C:\app\environment.yml

# Activate Conda environment
SHELL ["cmd", "/C"]
RUN conda init powershell && conda activate open3d

# Build ARAP Volume Tracking
WORKDIR C:\app\arap-volume-tracking
RUN dotnet build -c Release

# Build TVM Editing
WORKDIR C:\app\tvm-editing
RUN dotnet build TVMEditor.sln --configuration Release --no-incremental

# Set entry point script
CMD ["powershell", "C:\\app\\run_pipeline.ps1"]
