# dotfiles

## Install

```bash
git clone --branch release --depth 1 https://github.com/jeremija/dotfiles ~/dotfiles
cd ~/dotfiles
make install
```

## Mac OS

You can run `mac-setup` to install homebrew and its packages:

```bash
make mac-setup
```

## Uninstall

```bash
cd ~/dotfiles
make uninstall
```

**NOTE** Installation should not replace any existing files, but uninstall **WILL** remove them!

# node version manager (nvm)

To install `nvm` just run:

```bash
git clone https://github.com/creationix/nvm ~/.nvm
```
