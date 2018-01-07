all: clean org-to-markdown serve

org-to-markdown:
	emacs -batch -l ~/.emacs.d/init.el content-org/blog-posts.org --eval "(org-hugo-export-wim-to-md t)" --kill

serve:
	hugo server -D --navigateToChanged

clean:
	rm -rf content/*

.PHONY: clean serve org-to-markdown
