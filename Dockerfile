from base/archlinux:latest

run pacman -Syu
run pacman -S --noconfirm base base-devel neovim python3 python-neovim git \
zsh go rust cmake clang tmux nodejs npm fzf ripgrep python-virtualenv openssh && \
paccache -rk 0
run echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
run locale-gen

arg USER=user

run useradd -u 1000 -m ${USER}
user ${USER}
workdir /home/${USER}
run git clone  https://github.com/jeremija/dotfiles

workdir /home/${USER}/dotfiles
run mkdir -p ../.config
run git submodule update --init --recursive
run make install

workdir /home/${USER}
run git clone https://github.com/creationix/nvm .nvm
run zsh -c 'source .nvm/nvm.sh'

run mkdir opt && cd opt && zsh -c 'source ../.nvm/nvm.sh && npm install typescript'

workdir /home/${USER}

run mkdir -p src/go src/rust src/js src/python
run mkdir bin && ln -s /usr/bin/nvim bin/vim
env SHELL=/bin/zsh
entrypoint ["/bin/zsh"]
