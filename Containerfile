FROM mcr.microsoft.com/devcontainers/base:2.0.3-ubuntu24.04@sha256:daa08ddb48ad4e4e7367c348e0a6f250762f1f0d8348f1f9acbef5f884ce093d

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
    curl \
    wget \
    fonts-powerline \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh && \
    rm -rf /var/lib/apt/lists/*

# Switch to non-root user
USER vscode

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


COPY --chown=vscode:vscode .zshrc .p10k.zsh /home/vscode/

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
