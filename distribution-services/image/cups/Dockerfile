# Use the official CUPS image as the base image
FROM debian:buster-slim

# Install CUPS
RUN apt-get update && apt-get install -y \
    cups \
    && rm -rf /var/lib/apt/lists/*

# Expose the CUPS port
EXPOSE 631

# Start CUPS when the container is run
CMD ["cupsd", "-f"]
