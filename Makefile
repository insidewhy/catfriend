.PHONY: dist

dist:
	ver=`git tag | tail -n 1`; \
	git archive --prefix=catfriend-$$ver/ $$ver | \
		gzip > catfriend-$$ver.tar.gz -
