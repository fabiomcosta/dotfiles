install:
	bash install.sh

update:
	git submodule foreach 'git pull origin master'

