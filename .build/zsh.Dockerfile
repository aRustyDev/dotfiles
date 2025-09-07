FROM debian:stable-slim AS setup

ARG USER=main
ARG UID=1000
ARG GID=1000

# Let scripts know we're running in Docker (useful for containerised development)
ENV RUNNING_IN_DOCKER=true
ENV VOLTA_HOME "/root/.volta"
ENV PATH "$VOLTA_HOME/bin:$PATH"
# Use the unprivileged `main` USER (created without a password) for safety
# RUN useradd -m ${USER}
# RUN mkdir -p /app \
#     && chown -R ${USER}:${USER} /app

COPY .build/apt/sources/* /etc/apt/sources.list.d/
COPY .build/apt/keyrings/* /etc/apt/keyrings/

# Set up base system and development tools
RUN apt-get update && apt-get install -y bash zsh curl git ripgrep
ENV SHELL=/bin/zsh
RUN apt-get install -y \
    libtk8.6 libxml2-dev linux-headers-generic xz-utils \
    liblzma-dev libgdbm-dev uuid-dev lsb-release gnupg2 \
    libfreetype6-dev libfontconfig1-dev libcairo2-dev \
    build-essential gcc coreutils apt-transport-https\
    zlib1g-dev libssl-dev libreadline-dev libffi-dev \
    libbz2-dev libsqlite3-dev libncurses5-dev \
    ca-certificates libncursesw5-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get install -y \
    zoxide jq yq neovim bat wget gawk grep sed shellcheck \
    fzf ffmpeg 7zip poppler-utils fd-find imagemagick \
    texinfo tenv kubectl starship helm just eza unzip shfmt

# # Install tools not available in standard Debian repos
# # Install kubectl
# RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
#     && chmod +x kubectl \
#     && mv kubectl /usr/local/bin/

# # Install helm
# RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# # Install starship
# RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# Install zoxide
# RUN curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# # Install just
# RUN curl --proto '=https' --tlsv1.2 -LsSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

# # Install tenv
# RUN TENV_VERSION=$(curl -s "https://api.github.com/repos/tofuutils/tenv/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/') \
#     && curl -L "https://github.com/tofuutils/tenv/releases/latest/download/tenv_${TENV_VERSION}_amd64.deb" -o tenv.deb \
#     && dpkg -i tenv.deb \
#     && rm tenv.deb

# Install mise
RUN curl https://mise.run | sh

# # Install eza (modern ls replacement)
# RUN curl -L https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz | tar xz \
#     && mv eza /usr/local/bin/

# Install k9s
RUN K9S_VERSION=$(curl -s "https://api.github.com/repos/derailed/k9s/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/') \
    && curl -L "https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_amd64.tar.gz" | tar xz \
    && mv k9s /usr/local/bin/

# Install yazi
RUN YAZI_VERSION=$(curl -s "https://api.github.com/repos/sxyazi/yazi/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/') \
    && curl -L "https://github.com/sxyazi/yazi/releases/download/v${YAZI_VERSION}/yazi-x86_64-unknown-linux-gnu.zip" -o yazi.zip \
    && unzip yazi.zip \
    && mv yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin/ \
    && rm -rf yazi.zip yazi-x86_64-unknown-linux-gnu

# # Install shfmt
# RUN SHFMT_VERSION=$(curl -s "https://api.github.com/repos/mvdan/sh/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/') \
#     && curl -L "https://github.com/mvdan/sh/releases/download/v${SHFMT_VERSION}/shfmt_v${SHFMT_VERSION}_linux_amd64" -o /usr/local/bin/shfmt \
#     && chmod +x /usr/local/bin/shfmt

# Note: nerd-fonts would need to be installed differently in Debian
# You might want to install specific fonts instead

# Create group and user with Debian commands
RUN groupadd --gid "$GID" "$USER" && \
    useradd --uid "$UID" --gid "$USER" --create-home --shell /bin/zsh "$USER"

# Copy config files to the new user's home
RUN chown -R $USER:$USER /home/$USER

# Switch to the unprivileged user
USER $USER

# === === === [ BASH ] === === ===
COPY bash/.bashrc /root/.bashrc
COPY bash/.bashrc /home/$USER/.bashrc
# COPY bash/profile/etc /etc/profile
# COPY bash/profile/d/* /etc/profile.d/
# COPY bash/profile/user /home/$USER/.bash_profile

# === === === [ ZSH ] === === ===
# COPY zsh/env/etc /etc/zshenv
# COPY zsh/env/user /home/$USER/zshenv
# COPY zsh/env/root /root/zshenv

# COPY zsh/login/etc /etc/zlogin
# COPY zsh/login/user /home/$USER/.zlogin
# COPY zsh/login/root /root/.zlogin

COPY zsh/.zshrc /root/.zshrc
COPY zsh/.zshrc /home/$USER/.zshrc
# COPY zsh/rc/etc /etc/zshrc
# COPY zsh/rc/user /home/$USER/.zshrc
# COPY zsh/rc/root /root/.zshrc

# COPY zsh/profile/etc /etc/profile
# COPY zsh/profile/d/* /etc/profile.d/
# COPY zsh/profile/user /home/$USER/.zsh_profile
# COPY zsh/profile/root /root/.zsh_profile

RUN source /home/$USER/.zshrc && \
    source /home/$USER/.bashrc

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
ENV PATH="/home/$USER/.cargo/bin:${PATH}"

# Install Pyenv
RUN curl https://pyenv.run | bash
ENV PATH="/home/$USER/.pyenv/bin:${PATH}"

# Install Volta (this should work now with glibc)
RUN curl https://get.volta.sh | bash

# Install PNPM
RUN curl -fsSL https://get.pnpm.io/install.sh | sh -
ENV PNPM_HOME="/root/.local/share/pnpm"
ENV PATH="${PNPM_HOME}:${PATH}"

# Source cargo environment and install Rust tools
RUN . "$HOME/.cargo/env" && \
    cargo install atuin resvg tealdeer lsd

# # Install helm-ls via Volta
# RUN bash -c "source /root/.bashrc && volta install helm-ls"

# Install antidote
RUN git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote

WORKDIR /home/$USER
ENTRYPOINT [ "/bin/zsh" ]
