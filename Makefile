all: clean-md clean-html org-to-markdown serve

org-to-markdown:
	emacs -batch -l ~/.emacs.d/init.el content-org/blog-posts.org --eval "(org-hugo-export-wim-to-md t)" --kill

serve:
	hugo server -D --navigateToChanged

clean-md:
	rm -rf content/*

.PHONY: clean-md serve org-to-markdown clean-html
	rm -rf /public/*
