FROM mcr.microsoft.com/devcontainers/base:2.1.6-trixie@sha256:a30da48cdf5f9144ff7f2156622e701e752fc258d77ca7bb00120624f1a95938

ENV TZ="Europe/Berlin" 

# Set environment variable to help with container orientation
ENV DEVCONTAINER=true

# additional project dependencies including zsh and GitHub CLI
RUN apt-get update && apt-get install -y \
    git \
    zsh \
    fzf \
    curl \
    wget \
    fontconfig \
    && rm -rf /var/lib/apt/lists/*

# Switch to non-root user
USER vscode

# Install JetBrainsMono Nerd Font (recommended for starship)
RUN mkdir -p ~/.local/share/fonts && \
    curl -fLo /tmp/JetBrainsMono.tar.xz \
    https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.tar.xz && \
    tar -xf /tmp/JetBrainsMono.tar.xz -C ~/.local/share/fonts && \
    rm /tmp/JetBrainsMono.tar.xz && \
    fc-cache -fv

# Set zsh as default shell and configure it
RUN git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Copy zsh configuration files
COPY --chown=vscode:vscode .zshrc /home/vscode/

# Set the default shell to zsh rather than sh
ENV SHELL=/bin/zsh

# Set working directory
WORKDIR /workspaces
