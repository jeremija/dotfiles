from ubuntu:latest

run apt-get -y update &&  \
    apt-get install --no-install-recommends -y \
    curl \
    base \
    build-essential \
    git \
    zsh \
    golang \
    rustup \
    cmake \
    clang \
    tmux \
    nodejs \
    npm \
    fzf \
    ripgrep \
    python3-virtualenv \
    ssh \
    && \
    rm -rf /var/lib/apt/lists/*

env EDITOR=nvim

user ubuntu
workdir /home/ubuntu
run git clone https://github.com/creationix/nvm .nvm

run mkdir opt && cd opt && zsh -c 'source ../.nvm/nvm.sh && npm install typescript'
run rustup default stable
run rustup component add rust-src rust-analyzer

ARG NVIM_VERSION=0.11.1
ARG ARCH

user root
RUN case "${ARCH:-$(dpkg --print-architecture)}" in \
        amd64) NVIM_ARCH="nvim-linux64";; \
        arm64) NVIM_ARCH="nvim-linux-arm64";; \
        *) echo "Unsupported architecture: $ARCH"; exit 1;; \
    esac && \
    echo "Installing Neovim $NVIM_VERSION for $NVIM_ARCH" && \
    curl -L -o nvim.tar.gz https://github.com/neovim/neovim/releases/download/v$NVIM_VERSION/$NVIM_ARCH.tar.gz && \
    tar -xzf nvim.tar.gz && \
    mv $NVIM_ARCH /usr/local/nvim && \
    ln -s /usr/local/nvim/bin/nvim /usr/local/bin/nvim && \
    rm nvim.tar.gz

user ubuntu
run mkdir -p src/go src/rust src/js src/python
run mkdir -p bin && ln -s /usr/bin/nvim bin/vim

copy . dotfiles

workdir /home/ubuntu/dotfiles
run mkdir -p ../.config
run make install

workdir /home/ubuntu

env SHELL=/bin/zsh
entrypoint ["/bin/zsh"]
