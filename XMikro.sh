#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

REPO_DIR="/root/XrayR-release"
OUTPUT_DIR="$REPO_DIR/output"
WEBSERVER_PID_FILE="$REPO_DIR/webserver.pid"
DOCKER_IMAGE_NAME="xrayr-mds"
DOCKERFILE_URL="https://raw.githubusercontent.com/SudoMds/XrayR-Mikrotik/refs/heads/main/Dockerfile"

log() {
    echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

stop_webserver() {
    if [ -f "$WEBSERVER_PID_FILE" ]; then
        PID=$(cat "$WEBSERVER_PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            kill "$PID"
            rm -f "$WEBSERVER_PID_FILE"
            echo -e "${GREEN}✅ Web server stopped.${NC}"
            log "Web server stopped"
        else
            echo -e "${YELLOW}⚠️  Web server process not found. Removing stale PID file.${NC}"
            rm -f "$WEBSERVER_PID_FILE"
        fi
    else
        echo -e "${YELLOW}⚠️  Web server is not running.${NC}"
    fi
}

while true; do
    clear
    echo -e "==============================="
    echo -e "        ${CYAN}XrayR Setup Script${NC}        "
    echo -e "==============================="
    echo
    echo -e " 1) ${YELLOW}Clone XrayR-release repository${NC}"
    echo -e "    Download the official XrayR project source code."
    echo
    echo -e " 2) ${YELLOW}Install dependencies & download Dockerfile${NC}"
    echo -e "    Installs docker, nano, python3 and gets the custom Dockerfile."
    echo -e "    Automatically installs missing packages."
    echo
    echo -e " 3) ${YELLOW}Edit config.yml${NC}"
    echo -e "    Open config/config.yml file in nano editor to customize settings."
    echo
    echo -e " 4) ${YELLOW}Build Docker image${NC}"
    echo -e "    Build the Docker image named '${DOCKER_IMAGE_NAME}' using Dockerfile."
    echo
    echo -e " 5) ${YELLOW}Save Docker image to tar file${NC}"
    echo -e "    Save the built image into output/${DOCKER_IMAGE_NAME}.tar for transfer."
    echo -e "    Then remove the Docker image to free space for next build."
    echo
    echo -e " 6) ${YELLOW}Run web server to share output folder${NC}"
    echo -e "    Start a simple HTTP server so you can download the image file."
    echo
    echo -e " 7) ${YELLOW}Stop web server${NC}"
    echo -e "    Stops the HTTP server if it is running."
    echo
    echo -e " 8) ${YELLOW}Exit${NC}"
    echo
    echo -e "-------------------------------"
    echo -e "Built by: ${GREEN}Sudo.MDS${NC} | Build date: ${GREEN}2025-07-20${NC}"
    echo -e "==============================="
    echo -ne "Choose an option [1-8]: "
    read -r option

    case $option in
        1)
            if [ -d "$REPO_DIR" ]; then
                echo -e "${YELLOW}Directory $REPO_DIR already exists. Pulling latest changes...${NC}"
                cd "$REPO_DIR" && git pull
            else
                git clone https://github.com/XrayR-project/XrayR-release.git "$REPO_DIR"
            fi
            read -rp "Press Enter to continue..."
            ;;
        2)
            echo -e "${GREEN}Updating system and installing packages...${NC}"
            sudo apt update && sudo apt install -y docker.io nano python3 wget git
            sudo systemctl enable --now docker
            docker run --privileged --rm tonistiigi/binfmt --install all
            mkdir -p "$REPO_DIR"
            wget -O "$REPO_DIR/Dockerfile" "$DOCKERFILE_URL"
            echo -e "${GREEN}Dependencies installed and Dockerfile downloaded to $REPO_DIR.${NC}"
            read -rp "Press Enter to continue..."
            ;;
        3)
            if [ ! -f "$REPO_DIR/config/config.yml" ]; then
                echo -e "${RED}Config file not found. Please run step 1 first.${NC}"
                read -rp "Press Enter to continue..."
                continue
            fi
            echo -e "${GREEN}Opening config file with nano...${NC}"
            echo -e "Config file path: ${CYAN}$REPO_DIR/config/config.yml${NC}"
            nano "$REPO_DIR/config/config.yml"
            ;;
        4)
            if [ ! -f "$REPO_DIR/Dockerfile" ]; then
                echo -e "${RED}Dockerfile not found! Please run step 2 first.${NC}"
                read -rp "Press Enter to continue..."
                continue
            fi
            cd "$REPO_DIR" || { echo -e "${RED}Failed to cd to $REPO_DIR${NC}"; read -rp "Press Enter..."; continue; }
            echo -e "${GREEN}Building Docker image ${DOCKER_IMAGE_NAME}...${NC}"
            docker build -t "${DOCKER_IMAGE_NAME}" .
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ Docker image built successfully.${NC}"
            else
                echo -e "${RED}❌ Docker build failed.${NC}"
            fi
            read -rp "Press Enter to continue..."
            ;;
        5)
            mkdir -p "$OUTPUT_DIR"
            echo -e "${GREEN}Saving Docker image to tar file...${NC}"
            docker save -o "$OUTPUT_DIR/${DOCKER_IMAGE_NAME}.tar" "${DOCKER_IMAGE_NAME}"
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ Docker image saved to $OUTPUT_DIR/${DOCKER_IMAGE_NAME}.tar${NC}"
                echo -e "You can transfer this .tar file to other machines."
                echo -e "${YELLOW}Removing Docker image ${DOCKER_IMAGE_NAME} to free space...${NC}"
                docker rmi "${DOCKER_IMAGE_NAME}"
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ Docker image removed successfully.${NC}"
                else
                    echo -e "${RED}❌ Failed to remove Docker image.${NC}"
                fi
            else
                echo -e "${RED}❌ Failed to save Docker image.${NC}"
            fi
            read -rp "Press Enter to continue..."
            ;;
        6)
            if [ ! -d "$OUTPUT_DIR" ]; then
                echo -e "${RED}Output directory $OUTPUT_DIR not found. Please save image first (Step 5).${NC}"
                read -rp "Press Enter to continue..."
                continue
            fi
            if [ -f "$WEBSERVER_PID_FILE" ]; then
                echo -e "${YELLOW}Web server is already running. Stop it first from menu option 7.${NC}"
                read -rp "Press Enter to continue..."
                continue
            fi
            read -rp "Enter port for web server [default 8000]: " port
            port=${port:-8000}
            cd "$OUTPUT_DIR" || { echo -e "${RED}Failed to cd to $OUTPUT_DIR${NC}"; read -rp "Press Enter..."; continue; }
            echo "Starting web server at http://$(hostname -I | awk '{print $1}'):$port/"
            python3 -m http.server "$port" > /dev/null 2>&1 &
            echo $! > "$WEBSERVER_PID_FILE"
            echo -e "${GREEN}✅ Web server started. Access your files at:${NC}"
            echo -e "${CYAN}http://$(hostname -I | awk '{print $1}'):$port/${NC}"
            read -rp "Press Enter to continue..."
            ;;
        7)
            stop_webserver
            read -rp "Press Enter to continue..."
            ;;
        8)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Try again.${NC}"
            sleep 1
            ;;
    esac
done
