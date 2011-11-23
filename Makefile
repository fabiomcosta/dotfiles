install-vim-plugin install:
	@[ "$(repo)" ] || (echo "define a repo. (make install repo=url.git)" && exit 1)
	@repo="$(repo)"; \
		repo_name=$$(basename $$repo); \
		repo_name=$${repo_name%%.*}; \
		git submodule add $$repo vim/.vim/bundle/$$repo_name;

update:
	git submodule foreach 'git pull origin master'

# setups the necessary stuff for the first time you clone this repository
setup:
	bash install.sh

.PHONY: install setup update
