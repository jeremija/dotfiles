export HOMEBREW_NO_AUTO_UPDATE=1

install: FORCE
	./install.sh

uninstall: FORCE
	./install.sh --uninstall

mac-setup: mac-tweaks mac-homebrew mac-brew mac-cask

mac-homebrew: FORCE
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	cat brew.tap | xargs brew tap

mac-backup: FORCE
	brew tap > brew.tap
	brew cask list > brew.cask.list
	brew leaves > brew.leaves

mac-brew: FORCE
	brew install $(cat brew.leaves)

mac-cask: FORCE
	brew cask install $(cat brew.cask.list)

mac-tweaks: FORCE
	defaults write com.apple.dock autohide-time-modifier -int 0
	killall Dock

submodules: FORCE
	git submodule update --init --recursive

flatten: FORCE
	./flatten.sh

FORCE:
