FROM ghcr.io/xrayr-project/xrayr:latest

# Copy custom config.yml into the container
COPY /config/config.yml /etc/XrayR/config.yml
