all: clean-html clean-markdown org-to-markdown watch

.PHONY: org-to-markdown
org-to-markdown:
	emacs -batch -l ~/.emacs.d/init.el content-org/blog-posts.org --eval "(org-hugo-export-wim-to-md t)" --kill

.PHONY: markdown-to-html
markdown-to-html:
	hugo

.PHONY: watch
watch:
	hugo server --buildDrafts --navigateToChanged --cleanDestinationDir

.PHONY: clean-markdown
clean-markdown:
	rm -rf content/*

.PHONY: clean-html
clean-html:
	rm -rf public/*

.PHONY: clean
clean: clean-markdown clean-html

.PHONY: publish
publish:
	./publish_to_ghpages.sh
