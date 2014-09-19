all: build

build:
	coffee --output lib --compile src

.PHONY: test
test: build
	mocha test \
		--require should \
		--compilers coffee:coffee-script/register
