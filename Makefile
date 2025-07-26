.PHONY: dev themes

dev:
	hugo server \
		--buildDrafts \
		--disableFastRender \
		--navigateToChanged \
		--printI18nWarnings

themes:
	hugo mod get github.com/goofansu/hugo-modus
