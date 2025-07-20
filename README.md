# XrayR-Mikrotik 🛡️

**XrayR-Mikrotik** is a tool designed to create and deploy a fully working **XrayR** container on **MikroTik RouterOS** using the MikroTik **Container** feature. This script resolves the issues with running the original XrayR Docker image on MikroTik by preparing a compatible `.tar` container package.

---

## ❓ What is This Tool?

Many users encounter issues when deploying the original XrayR Docker image on MikroTik, such as:

- Config files like `config.yml` not being loaded  
- Container crashes and stops unexpectedly  

**XrayR-Mikrotik** solves these problems by automating the build process and preparing a MikroTik-compatible container image that:

✅ Loads your configuration correctly  
✅ Boots without errors on MikroTik RouterOS  
✅ Is packaged in `.tar` format for direct import  

---

## 🛠 Features

- 🔧 Pre-configures and edits your `config.yml`  
- 🐳 Builds a working XrayR Docker image  
- 📦 Saves the image as a `.tar` file  
- 🌐 Optionally runs a temporary web server to serve the `.tar`  
- 🤝 Fully compatible with MikroTik's Container system  

---

## 🚀 Quick Setup (Linux)

Run this script on **any Linux server** (Debian, Ubuntu, CentOS):

```bash
wget https://raw.githubusercontent.com/SudoMds/XrayR-Mikrotik/refs/heads/main/XMikro.sh
chmod +x XMikro.sh
bash XMikro.sh
```

Follow the interactive steps to build and export the container image.

> ⚠️ If you start the temporary web server (to download the image from MikroTik), don’t forget to stop it using the provided option at the end.

---

## 🔧 What Does the Script Do?

- Clones the XrayR GitHub repository  
- Downloads a custom Dockerfile  
- Allows you to edit your `config.yml`  
- Builds the customized Docker image  
- Saves it as a `.tar` file  
- *(Optional)* Hosts the `.tar` over a simple HTTP server  
- *(Optional)* Stops the HTTP server  

---

## 📦 MikroTik Container Setup

### Step 1: Network Configuration (CLI)

Open the MikroTik terminal and run:

```shell
/interface bridge add name=docker comment="Docker Container Bridge"
/ip address add address=172.0.0.1/24 interface=docker comment="Docker Bridge IP"
/interface veth add name=veth-docker address=172.0.0.2/24 gateway=172.0.0.1 comment="Container Virtual NIC"
/interface bridge port add bridge=docker interface=veth-docker
/ip firewall nat add chain=srcnat out-interface=docker action=masquerade comment="NAT for Containers"
```

---

### Step 2: Upload Container

1. From your Linux server, download the `.tar` image created by the script.
2. Upload the image to your MikroTik via **Winbox**, **WebFig**, or **SCP**.
3. Place it in a new root folder, for example:  
   `/container/xrayr`

---

### Step 3: Configure Container in Winbox

Go to: `System → Container`  
Click `+` to add a new container

| Setting        | Value                     |
|----------------|---------------------------|
| **File**       | `xrayr-xxxx.tar`          |
| **Root Dir**   | `/container/xrayr`        |
| **Interface**  | `veth-docker`             |
| **DNS**        | `1.1.1.1, 8.8.8.8`        |
| **Start on Boot** | ☑️ Enabled          |

Right-click on the container and choose **Start**  
✅ Make sure the status shows **running**

---

## 🧠 Credits

Made with ❤️ by [@SudoMds](https://github.com/SudoMds)
