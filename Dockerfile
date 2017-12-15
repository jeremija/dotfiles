from base/archlinux:latest

run pacman -Syu
run pacman -S --noconfirm base-devel neovim python3 python-neovim git \
zsh go rust cmake clang tmux nodejs npm fzf ripgrep virtualenv
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
run cat .vimrc | sed '/plug#end/q' > .vimrc.install
run nvim --headless -u .vimrc.install +'PlugInstall --sync' +qa

run mkdir -p src/go src/rust src/js src/python
run mkdir bin && ln -s /usr/bin/nvim vim
env SHELL=/bin/zsh
entrypoint ["/bin/zsh"]
