# Use Windows Server Core as base
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set working directory
WORKDIR C:\\app

RUN @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

# Install Visual Studio 2022 Build Tools, Python, and Git
RUN choco install git python miniconda cmake -y

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

RUN `
    # Download the Build Tools bootstrapper.
    curl -SL --output vs_buildtools.exe https://aka.ms/vs/17/release/vs_buildtools.exe `
    `
    # Install Build Tools with the Microsoft.VisualStudio.Workload.AzureBuildTools workload, excluding workloads and components with known issues.
    && (start /w vs_buildtools.exe --quiet --wait --norestart --nocache `
        --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools" `
        --add Microsoft.VisualStudio.Workload.AzureBuildTools `
        --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 `
        --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 `
        --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 `
        --remove Microsoft.VisualStudio.Component.Windows81SDK `
        || IF "%ERRORLEVEL%"=="3010" EXIT 0) `
    `
    # Cleanup
    && del /q vs_buildtools.exe

# Define the entry point for the docker container.
# This entry point starts the developer command prompt and launches the PowerShell shell.
ENT

# Clone Draco repository
RUN git clone https://github.com/google/draco.git C:\app\draco \
    && cd C:\app\draco \
    && mkdir build && cd build \
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
