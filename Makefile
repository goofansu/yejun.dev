.PHONY: dev prod local remote

dev: local
	hugo server --disableFastRender --navigateToChanged

prod: remote
	hugo mod get -u
	hugo mod tidy

local:
	@if ! grep -q "^replace" go.mod; then \
		sed -i 's/^\/\/ replace/replace/' go.mod; \
		echo "Switched to local modules"; \
		hugo mod tidy; \
	fi

remote:
	@if grep -q "^replace" go.mod; then \
		sed -i 's/^replace/\/\/ replace/' go.mod; \
		echo "Switched to remote modules"; \
		hugo mod tidy; \
	fi
