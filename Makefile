PACKAGE := $(shell grep '^Package:' DESCRIPTION | sed -E 's/^Package:[[:space:]]+//')
RSCRIPT = Rscript --no-init-file

all: install

test:
	${RSCRIPT} -e 'library(methods); devtools::test()'

roxygen:
	@mkdir -p man
	${RSCRIPT} -e "library(methods); devtools::document()"

install:
	R CMD INSTALL .

build:
	R CMD build .

check: build
	_R_CHECK_CRAN_INCOMING_=FALSE R CMD check --as-cran --no-manual `ls -1tr ${PACKAGE}*gz | tail -n1`
	@rm -f `ls -1tr ${PACKAGE}*gz | tail -n1`
	@rm -rf ${PACKAGE}.Rcheck

vignettes: vignettes/jsonvalidate.Rmd
	${RSCRIPT} -e 'library(methods); devtools::build_vignettes()'

staticdocs:
	@mkdir -p inst/staticdocs
	${RSCRIPT} -e "library(methods); staticdocs::build_site()"
	rm -f vignettes/*.html
	@rmdir inst/staticdocs
website: staticdocs
	./update_web.sh

js/bundle.js: js/package.json js/in.js
	./js/prepare

inst/bundle.js: js/bundle.js
	cp $< $@
	cp js/node_modules/ajv/LICENSE inst/LICENSE.ajv
	cp js/node_modules/is-my-json-valid/LICENSE inst/LICENSE.is-my-json-valid

# No real targets!
.PHONY: all test document install vignettes
