all: clean-markdown clean-html org-to-markdown watch

.PHONY: org-to-markdown
org-to-markdown:
	emacs -batch -l ~/.emacs.d/init.el content-org/blog-posts.org --eval "(org-hugo-export-wim-to-md t)" --kill

.PHONY: markdown-to-org
markdown-to-org:
	hugo

.PHONY: watch
watch:
	hugo server --buildDrafts --navigateToChanged

.PHONY: clean-markdown
clean-markdown:
	rm -rf content/*

.PHONY: clean-html
clean-html:
	rm -rf public/*

.PHONY: clean
clean: clean-html clean-markdown
