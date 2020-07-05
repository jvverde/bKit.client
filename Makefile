PREFIX ?= ~/.bkit

install:
	cp -av * $(PREFIX)/bin/

uninstall:
	rm -rf $(PREFIX)/bin/*
