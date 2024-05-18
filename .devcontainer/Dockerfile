#####################################################
# Copied from jetpackio/devbox
# https://github.com/jetify-com/devbox/blob/main/internal/devbox/generate/tmpl/DevboxImageDockerfile
# CHANGES:
# - The FROM
# - The USER:
#   - Switch to root to install dependencies
#   - Changed from devbox to vscode
#   - Don't create a new user
#   - Use the variable when updating the sudoers file
#####################################################

# FROM debian:stable-slim
FROM mcr.microsoft.com/devcontainers/base:debian

# Step 1: Installing dependencies
RUN apt-get update
RUN apt-get -y install bash binutils git xz-utils wget sudo

# Step 1.5: Setting up devbox user
USER root
# ENV DEVBOX_USER=devbox
ENV DEVBOX_USER=vscode
# RUN adduser $DEVBOX_USER
RUN usermod -aG sudo $DEVBOX_USER
# RUN echo "devbox ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$DEVBOX_USER
RUN echo "${DEVBOX_USER} ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$DEVBOX_USER
USER $DEVBOX_USER

# Step 2: Installing Nix
RUN wget --output-document=/dev/stdout https://nixos.org/nix/install | sh -s -- --no-daemon
RUN . ~/.nix-profile/etc/profile.d/nix.sh

ENV PATH="/home/${DEVBOX_USER}/.nix-profile/bin:$PATH"

# Step 3: Installing devbox
RUN wget --quiet --output-document=/dev/stdout https://get.jetify.com/devbox   | bash -s -- -f
RUN chown -R "${DEVBOX_USER}:${DEVBOX_USER}" /usr/local/bin/devbox

CMD ["devbox", "version"]
#####################################################
# FROM jetpackio/devbox:latest
# mcr.microsoft.com/devcontainers/go:1-1.22-bullseye

# Installing your devbox project
WORKDIR /code
USER root:root
RUN mkdir -p /code && chown ${DEVBOX_USER}:${DEVBOX_USER} /code
USER ${DEVBOX_USER}:${DEVBOX_USER}
COPY --chown=${DEVBOX_USER}:${DEVBOX_USER} devbox.json devbox.json
COPY --chown=${DEVBOX_USER}:${DEVBOX_USER} devbox.lock devbox.lock



RUN devbox run -- echo "Installed Packages."

RUN devbox shellenv --init-hook >> ~/.profile
