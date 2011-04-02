.PHONY: build test dist

O := .obj

ifeq ($(wildcard ${O}),)

build:
	mkdir ${O} && cd ${O} && cmake ..

else
.PHONY: clean

build:
	${MAKE} -C ${O}

clean:
	rm -rf ${O}

endif

test:
	${MAKE} -C test

dist:
	ver=`git tag | tail -n 1`; \
	git archive --prefix=catfriend-$$ver/ $$ver | \
		gzip > catfriend-$$ver.tar.gz -

-include Makefile.local
