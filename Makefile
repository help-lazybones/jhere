.PHONY: dist test

PLUGIN = jhere
TESTED_CODE = test/lib/jhere.js
INJECTORS = $(shell cat test/lib/injectors.js | tr -d ' ')
RUNNER = test/SpecRunner.html

deps:
	@npm install

dist: hint plugin zepto extensions summary

plugin:
	@./node_modules/.bin/uglifyjs -nc -o dist/$(PLUGIN).min.js src/$(PLUGIN).js

zepto:
	@./node_modules/.bin/uglifyjs -nc -o dist/zepto.adapter.min.js src/zepto.adapter.js

extensions:
	@./build-scripts/build-extensions.sh

summary:
	@ls -nhl dist | grep -v ^d | awk '{print $$9,$$5}' | tail -n +2; \
	ls -nhl dist/extensions | grep -v ^d | awk '{print $$9,$$5}' | tail -n +2

hint:
	@./node_modules/.bin/jshint ./src

doc:
	@docco -t docs/docco.jst -o docs src/$(PLUGIN).js;mv docs/$(PLUGIN).html docs/docs.html; \
	[[ ${JHERE_GHPAGES} ]] && cp docs/docs.html ${JHERE_GHPAGES} && cp src/jhere.js ${JHERE_GHPAGES}/js

test: deps
	@sed 's/\/\*\*\*_\*\*\*\//$(INJECTORS)/g' src/$(PLUGIN).js > $(TESTED_CODE); \
	command -v phantomjs >/dev/null 2>&1 || { echo >&2 "PhantomJS not installed.  Run the tests from the browser."; exit 0; }; \
	./node_modules/.bin/phantom-jasmine $(RUNNER)