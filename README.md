# XrayR-Mikrotik
XrayR setup on Mikrotik Container

Just Bash the Script and Run it.

- wget https://raw.githubusercontent.com/SudoMds/XrayR-Mikrotik/refs/heads/main/XMikro.sh
- chmod +x XMikro.sh
- bash XMikro.sh
- Follow Script Steps and dont Forget to Stop WebServer at End if you Run it.

# XrayR Setup Script for MikroTik Container

This script automates the process of preparing a ready-to-run **XrayR** instance tailored for deployment inside a MikroTik container environment.

---

## Overview

XrayR is a flexible proxy/VPN tool commonly used for network traffic routing and obfuscation. This script streamlines the entire setup process by:

- Cloning the official XrayR project source code  
- Installing necessary dependencies including Docker, nano, and Python3  
- Downloading a custom Dockerfile optimized for MikroTik container deployment  
- Allowing you to edit `config.yml` easily during setup  
- Building the Docker image pre-configured with your settings  
- Saving the built image as a `.tar` file ready for import into MikroTik  
- Hosting a simple web server to conveniently share and download the `.tar` image  
- Cleaning up Docker images automatically after saving to reduce disk space usage  

---

## Why This Script?

MikroTik containers currently have limitations that prevent moving or mounting the `config.yml` file directly into the container at runtime. This causes issues for configuring XrayR properly within the MikroTik environment.

This script solves that by:

- Allowing you to **pre-configure** the `config.yml` file **before** building the Docker image  
- Embedding your custom configuration **inside** the Docker image itself  
- Delivering a ready-to-run Docker image `.tar` that MikroTik can import directly, fully configured and functional without needing to mount external config files  

This approach bypasses the container config mounting issue and ensures your XrayR instance runs smoothly inside MikroTik containers right after deployment.

---

## Features

- Step-by-step interactive menu-driven script  
- Installs and configures all required tools and packages  
- Ensures config file (`config/config.yml`) is easy to customize before build  
- Automatically builds and saves Docker images for MikroTik container use  
- Lightweight Python HTTP server to share output files on your local network  
- Cleans Docker environment by removing images after export  

---

## Requirements

- A Linux system with `sudo` privileges  
- Internet connection to clone repositories and download packages  
- Docker installed or will be installed by the script  
- MikroTik device capable of running container with imported Docker image  

---

## Usage

1. Run the script and follow the interactive menu to complete each step:  
   - Clone repository  
   - Install dependencies and download Dockerfile  
   - Edit `config.yml` to fit your setup  
   - Build Docker image  
   - Save image as `.tar` file  
   - Start web server to share the `.tar` file  
   - Stop web server when done  

2. Import the `.tar` Docker image into your MikroTik container environment.  
3. Deploy and run XrayR container with your customized config.

---

## Notes

- The saved Docker image `.tar` file is located in the `output` directory inside the cloned repo folder.  
- The script automatically removes the Docker image after saving to save disk space.  
- Web server runs on a port you specify and serves the `output` folder for easy file transfer.

---

## Built By

[Sudo.MDS](https://github.com/SudoMds)  
Build date: 2025-07-20

---

## License

MIT License

---

Feel free to contribute or report issues!
