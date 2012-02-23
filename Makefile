.PHONY: work home shutdown clean gem install-gem

cmd = ruby -Ilib ./bin/catfriend -fv
gem = $(wildcard *.gem)
project = catfriend

home:
	${cmd}

shutdown:
	${cmd}s

clean:
	rm -f *.gem

gem: catfriend.gemspec
	gem build $<

install-gem: $(wildcard *.gem)
	@[ -n "$^" ] || (echo "run make gem first"; exit 1)
	gem uninstall -ax ${project}
	gem install $<

work:
	${cmd}w
	
