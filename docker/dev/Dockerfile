FROM alpine:latest

LABEL maintainer="Daniel Edens <d.edens@domain.com>"
LABEL description="Development environment for Hammerspoon configuration"
LABEL version="1.0"

# Install basic dependencies
RUN apk add --no-cache \
    lua5.3 \
    lua5.3-dev \
    luarocks \
    git \
    curl \
    bash \
    make \
    gcc \
    g++ \
    libc-dev

# Install Lua linter and formatter
RUN luarocks install luacheck
RUN luarocks install luaformatter

# Set up working directory
WORKDIR /hammerspoon

# Copy project files
COPY . /hammerspoon/

# Create a directory structure that mirrors macOS for reference
RUN mkdir -p /hammerspoon/reference/home/.hammerspoon

# Create script to validate Lua syntax
RUN echo '#!/bin/sh\nluacheck --no-unused-args --no-unused-secondaries --no-max-line-length *.lua' > /hammerspoon/validate.sh && \
    chmod +x /hammerspoon/validate.sh

# Default command
CMD ["/bin/bash"] 
