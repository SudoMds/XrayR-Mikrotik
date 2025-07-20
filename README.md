### XrayR-Mikrotik 🛡️
XrayR-Mikrotik is a tool designed to create and deploy a fully working XrayR container on MikroTik RouterOS using the MikroTik Container feature. This script solves the problem of the original XrayR Docker image not running correctly on MikroTik by preparing a compatible .tar container package.

❓ What is This Tool?
Many users encounter issues when deploying the original XrayR Docker image on MikroTik. These include:

Config files like config.yml not being loaded.

Container crashes and stops unexpectedly.

XrayR-Mikrotik solves this by automating the build process and preparing a MikroTik-compatible container package that:

✅ Loads your configuration correctly
✅ Boots without errors on MikroTik RouterOS
✅ Is packaged in .tar format for direct import

🛠 Features
Pre-configures and edits your config.yml

Builds a working XrayR Docker image

Saves the image as a .tar file

Optionally runs a temporary web server to serve the .tar

Compatible with MikroTik's Container system

🚀 Quick Setup (Linux)
Run this script on any Linux server (Debian, Ubuntu, CentOS):

wget https://raw.githubusercontent.com/SudoMds/XrayR-Mikrotik/refs/heads/main/XMikro.sh
chmod +x XMikro.sh
bash XMikro.sh
Then follow the interactive steps.

⚠️ If you start the temporary web server (to download image from MikroTik), don’t forget to stop it using the provided option at the end.

🔧 What Does the Script Do?
Clones the XrayR GitHub repo

Downloads a custom Dockerfile

Allows you to edit your config.yml

Builds the customized Docker image

Saves it as a .tar file

(Optional) Hosts the .tar over a simple HTTP server

(Optional) Stops the HTTP server

📦 MikroTik Container Setup
Step 1: Network Configuration (CLI)
Open MikroTik terminal:


/interface bridge add name=docker comment="Docker Container Bridge"
/ip address add address=172.0.0.1/24 interface=docker comment="Docker Bridge IP"
/interface veth add name=veth-docker address=172.0.0.2/24 gateway=172.0.0.1 comment="Container Virtual NIC"
/interface bridge port add bridge=docker interface=veth-docker
/ip firewall nat add chain=srcnat out-interface=docker action=masquerade comment="NAT for Containers"
Step 2: Upload Container
From your Linux server, download the .tar image you created.

Upload it to your MikroTik using Winbox, WebFig, or SCP.

Place it in a new root folder, for example: /container/xrayr

Step 3: Configure Container in Winbox
Go to System → Container

Click + to add a new container

Settings:

Setting	Value
File	xrayr-xxxx.tar
Root Dir	/container/xrayr
Interface	veth-docker
DNS	1.1.1.1,8.8.8.8
Start on Boot	☑️

Right-click on the container and choose Start

✅ Verify that status shows running

🧠 Credits
Made with ❤️ by @SudoMds

