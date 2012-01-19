.PHONY: work home shutdown clean

cmd = ruby -Ilib ./bin/catfriend -fv

home:
	${cmd}

shutdown:
	${cmd}s

clean:
	rm -f *.gem

work:
	${cmd}w
	
