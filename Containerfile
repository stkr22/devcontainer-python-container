FROM mcr.microsoft.com/devcontainers/base:2.1.3-trixie@sha256:30b0a0c004ca94d36c323ee993361a7e0ae25ea255ea125201e8a9587501c324

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
    fonts-powerline \
    && rm -rf /var/lib/apt/lists/*

# Switch to non-root user
USER vscode

# MesloLGS
# Create fonts directory and download font files
# Download all 4 MesloLGS NF variants
RUN mkdir -p ~/.local/share/fonts && \
    wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -O "/home/vscode/.local/share/fonts/MesloLGS NF Regular.ttf" && \
    fc-cache -fv

# Install powerlevel10k theme
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# MesloLGS
# Create fonts directory and download font files
# Download all 4 MesloLGS NF variants
RUN mkdir -p ~/.local/share/fonts && \
    wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -O "/home/vscode/.local/share/fonts/MesloLGS NF Regular.ttf" && \
    fc-cache -fv

# Set zsh as default shell and configure it
RUN git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Copy zsh configuration files
COPY --chown=vscode:vscode .zshrc .p10k.zsh /home/vscode/

# Set the default shell to zsh rather than sh
ENV SHELL=/bin/zsh

# Set working directory
WORKDIR /workspaces
