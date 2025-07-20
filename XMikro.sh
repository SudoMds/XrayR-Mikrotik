#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

WORKDIR="$(pwd)/XrayR-release"
DOCKER_IMAGE_NAME="XrayR-MDS"
DEFAULT_TAR_NAME="${DOCKER_IMAGE_NAME}.tar"

function confirm() {
    # Usage: confirm "Your question?"
    while true; do
        read -rp "$1 [y/N]: " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]*|"" ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

while true; do
    echo -e "${GREEN}====== XrayR Setup Menu ======${NC}"
    echo "1. Step 1: Download Binary"
    echo "2. Step 2: Setup Needed Packages (docker, nano, python3)"
    echo "3. Step 3: config.yml Setup"
    echo "4. Step 4: Build Docker Image"
    echo "5. Step 5: Save Docker Image"
    echo "6. Step 6: Start HTTP Server to Serve Output"
    echo "0. Exit"
    echo "===================================="
    read -rp "Choose a step [0-6]: " choice
    echo ""

    case $choice in
        1)
            if [ -d "$WORKDIR" ]; then
                echo -e "${YELLOW}Directory '$WORKDIR' already exists.${NC}"
                if confirm "Do you want to overwrite it by cloning fresh? This will delete the existing folder."; then
                    rm -rf "$WORKDIR"
                else
                    echo "Skipping clone."
                    continue
                fi
            fi

            echo ">> Cloning XrayR-release..."
            if git clone https://github.com/XrayR-project/XrayR-release; then
                echo -e "${GREEN}✅ Cloned successfully.${NC}"
            else
                echo -e "${RED}❌ Git clone failed.${NC}"
            fi
            ;;
        2)
            if [ "$EUID" -ne 0 ]; then
                echo -e "${RED}You need to run Step 2 with root privileges (sudo).${NC}"
                continue
            fi

            echo ">> Installing Docker, nano, python3, and downloading Dockerfile..."

            apt update -qq
            apt install docker.io nano python3 -y

            systemctl enable --now docker

            echo ">> Installing multi-arch support..."
            docker run --privileged --rm tonistiigi/binfmt --install all > /dev/null 2>&1

            echo ">> Downloading Dockerfile..."
            if wget -q -O Dockerfile https://raw.githubusercontent.com/SudoMds/XrayR-Mikrotik/refs/heads/main/Dockerfile; then
                echo -e "${GREEN}✅ Dockerfile downloaded.${NC}"
            else
                echo -e "${RED}❌ Failed to download Dockerfile.${NC}"
            fi
            ;;
        3)
            if [ ! -d "$WORKDIR" ]; then
                echo -e "${RED}XrayR-release directory not found. Please run Step 1 first.${NC}"
                continue
            fi

            CONFIG_FILE="$WORKDIR/config/config.yml"
            echo ">> The configuration file is located at:"
            echo -e "${GREEN}$CONFIG_FILE${NC}"

            if [ -f "$CONFIG_FILE" ]; then
                if confirm "Do you want to edit it now using nano?"; then
                    nano "$CONFIG_FILE"
                    echo -e "${GREEN}✅ Config edited.${NC}"
                else
                    echo "You can edit it later manually using any editor."
                fi
            else
                echo -e "${RED}❌ config.yml not found at: $CONFIG_FILE${NC}"
            fi
            ;;
        4)
            if [ ! -f Dockerfile ]; then
                echo -e "${RED}Dockerfile not found in the current directory.${NC}"
                echo "Please run Step 2 to download the Dockerfile first."
                continue
            fi

            echo ">> About to build Docker image '${DOCKER_IMAGE_NAME}'."
            if confirm "Proceed with building the Docker image?"; then
                if docker build -t "$DOCKER_IMAGE_NAME" .; then
                    echo -e "${GREEN}✅ Docker image '${DOCKER_IMAGE_NAME}' built successfully.${NC}"
                else
                    echo -e "${RED}❌ Docker build failed.${NC}"
                fi
            else
                echo "Build cancelled."
            fi
            ;;
        5)
            if ! docker image inspect "$DOCKER_IMAGE_NAME" > /dev/null 2>&1; then
                echo -e "${RED}Docker image '${DOCKER_IMAGE_NAME}' not found. Please build it first (Step 4).${NC}"
                continue
            fi

            mkdir -p output
            echo "Default save file name: output/${DEFAULT_TAR_NAME}"
            read -rp "Enter filename to save Docker image inside output/ (or press enter for default): " tarname
            tarname=${tarname:-$DEFAULT_TAR_NAME}
            tarpath="output/$tarname"

            if [ -f "$tarpath" ]; then
                if ! confirm "File '$tarpath' exists. Overwrite?"; then
                    echo "Save cancelled."
                    continue
                fi
            fi

            echo ">> Saving Docker image '${DOCKER_IMAGE_NAME}' to '$tarpath'..."
            if docker save -o "$tarpath" "$DOCKER_IMAGE_NAME"; then
                echo -e "${GREEN}✅ Docker image saved to '$tarpath'.${NC}"
            else
                echo -e "${RED}❌ Failed to save Docker image.${NC}"
            fi
            ;;
        6)
            if [ ! -d output ]; then
                echo -e "${RED}Output folder not found. Please run Step 5 to save the image first.${NC}"
                continue
            fi

            # Check for python3 or python
            if command -v python3 > /dev/null 2>&1; then
                PYTHON_CMD="python3"
            elif command -v python > /dev/null 2>&1; then
                PYTHON_CMD="python"
            else
                echo -e "${RED}Python is not installed. Please install python3 or python.${NC}"
                continue
            fi

            read -rp "Enter port number to run the web server on [default: 8000]: " port
            port=${port:-8000}

            echo "Starting HTTP server to serve ./output on port $port"
            echo "Access your saved image at: http://<your-server-ip>:$port/"

            nohup $PYTHON_CMD -m http.server "$port" --directory output > /dev/null 2>&1 &

            echo -e "${GREEN}✅ HTTP server started on port $port.${NC}"
            echo "Run 'kill \$!' to stop it (replace \$! with the server PID)."
            ;;
        0)
            echo "Goodbye!"
            break
            ;;
        *)
            echo -e "${RED}Invalid choice. Try again.${NC}"
            ;;
    esac

    echo ""
done
