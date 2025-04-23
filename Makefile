.PHONY: dev

dev:
	hugo server \
		--buildDrafts \
		--disableFastRender \
		--navigateToChanged \
		--printI18nWarnings
