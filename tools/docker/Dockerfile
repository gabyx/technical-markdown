# syntax=docker/dockerfile:latest

ARG VERSION=latest

# Make full conversion image.
FROM gabyxgabyx/technical-markdown:$VERSION-minimal as technical-markdown
ARG USER_NAME="techmd"

ENV TECHMD_CONTAINER_NAME="Technical-Markdown"
COPY --chown=$USER_NAME:$USER_NAME tools /home/$USER_NAME/technical-markdown/tools
RUN find /home/$USER_NAME/technical-markdown/tools \
    -type f -and \( \
    -name "*.sh" \
    -or -name "*.lua" \
    -or -name "*.py" \) \
    -exec chmod +x {} \;

ENV TECHMD_TOOLS_DIR="/home/$USER_NAME/technical-markdown/tools"
ENV TECHMD_CONVERT_DIR="/home/$USER_NAME/technical-markdown/tools/convert"
ENV TECHMD_USE_SYSTEM_NODE="true"
