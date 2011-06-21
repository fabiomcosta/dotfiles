install:
	sh install

update:
	git submodule foreach 'git pull origin master'

