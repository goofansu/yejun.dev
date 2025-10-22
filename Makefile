.PHONY: dev update

dev:
	hugo server \
		--buildDrafts \
		--disableFastRender \
		--navigateToChanged \
		--printI18nWarnings

update:
	hugo mod get github.com/goofansu/hugo-modus; \
	git commit -am "update theme"
