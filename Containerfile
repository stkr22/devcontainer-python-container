FROM mcr.microsoft.com/devcontainers/base:2.0.4-ubuntu24.04@sha256:ad92cae7c25cafb1e7bb5aa7520b81be85fac022ea92e404b94a11127631fae3

ENV TZ="Europe/Berlin" 

# Install UV package manager
COPY --from=ghcr.io/astral-sh/uv:0.8.22@sha256:9874eb7afe5ca16c363fe80b294fe700e460df29a55532bbfea234a0f12eddb1 /uv /uvx /bin/

# Set up Python virtual environment
ENV VIRTUAL_ENV=/workspaces/.venv
ENV UV_PROJECT_ENVIRONMENT=/workspaces/.venv

# Create necessary directories and set permissions
RUN mkdir -p /workspaces /commandhistory && \
    chown -R vscode:vscode /workspaces /commandhistory

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

# NOTE: Node.js is installed for Claude Code extension which requires Node.js >=18
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && export NVM_DIR="$HOME/.nvm" \
    && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
    && nvm install 22 \
    && nvm use 22

ENV POWERLEVEL9K_DISABLE_GITSTATUS=true

# MesloLGS
# Create fonts directory and download font files
# Download all 4 MesloLGS NF variants
RUN mkdir -p ~/.local/share/fonts && \
    wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -O "/home/vscode/.local/share/fonts/MesloLGS NF Regular.ttf" && \
    fc-cache -fv

# Install powerlevel10k theme
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

ENV POWERLEVEL9K_DISABLE_GITSTATUS=true

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

# Create Claude configuration directory
RUN mkdir -p /home/vscode/.claude && \
    chown -R vscode:vscode /home/vscode/.claude

ENV CLAUDE_CONFIG_DIR=/home/vscode/.claude

# Install Claude Code (non-root installation for auto-updates)
RUN export PATH="~/.local/bin:$PATH"
RUN curl -fsSL https://claude.ai/install.sh | zsh -s latest

# Set up command history persistence for Claude Code
RUN SNIPPET="export PROMPT_COMMAND='history -a'" && \
    echo $SNIPPET >> /home/vscode/.bashrc && \
    echo $SNIPPET >> /home/vscode/.zshrc && \
    touch /commandhistory/.bash_history

# Set working directory
WORKDIR /workspaces
