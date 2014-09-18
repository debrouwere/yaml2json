all: build

build:
	coffee --output lib --compile src

.PHONY: test
test:
	./bin/yaml2json examples/musicman.md \
		--fussy \
		--convert-all \
		--pretty

#test: build
#	mocha test --require should --compilers coffee:coffee-script/register
