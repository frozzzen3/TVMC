# escape=`

# Use Windows Server Core as base
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set working directory
WORKDIR C:\\app

RUN @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

# Install Visual Studio 2022 Build Tools with all necessary components
RUN curl -o vs_buildtools.exe https://aka.ms/vs/17/release/vs_BuildTools.exe `
    && start /w vs_buildtools.exe --quiet --wait --norestart --nocache --installPath C:\BuildTools `  
        --add Microsoft.VisualStudio.Workload.VCTools `  
        --add Microsoft.VisualStudio.Component.VC.CMake.Project `  
        --add Microsoft.VisualStudio.Component.Windows10SDK.20348 ` 
    && del vs_buildtools.exe


# Install Visual Studio 2022 Build Tools, Python, and Git
RUN choco install git python miniconda cmake -y

# Clone Draco repository
RUN git clone https://github.com/google/draco.git C:\app\draco `
    && cd C:\app\draco `
    && mkdir build && cd build `
    && cmake .. -G "Visual Studio 17 2022" -A x64 \
#     && cmake --build . --config Release

# # Clone TVMC project
# RUN git clone https://github.com/frozzzen3/TVMC.git C:\app\TVMC

# # Copy project files
# COPY . C:\app

# # Set up Conda and install Python dependencies from environment.yml
# RUN conda env create -f C:\app\TVMC\environment.yml

# # Activate Conda environment
# SHELL ["cmd", "/C"]
# RUN conda init powershell && conda activate open3d

# # Build ARAP Volume Tracking
# WORKDIR C:\app\arap-volume-tracking
# RUN dotnet build -c Release

# # Build TVM Editing
# WORKDIR C:\app\tvm-editing
# RUN dotnet build TVMEditor.sln --configuration Release --no-incremental

# # Set entry point script
# CMD ["powershell", "C:\\app\\run_pipeline.ps1"]
