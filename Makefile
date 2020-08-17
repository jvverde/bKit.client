PREFIX ?= ~/.bkit
SHELL := env PATH=$(PATH) /bin/bash
install:
	mkdir -pv $(PREFIX)/bin
	cp -av * $(PREFIX)/bin/
	chmod 755 $(PREFIX)/bin/*.sh
	touch ~/.bashrc
	echo export PATH=$(PREFIX)/bin:\$$PATH >> ~/.bashrc
	perl -i."$(shell date --iso-8601=seconds)" -ne 'print unless $$seen{$$_}++ && m#^export PATH=.+#' ~/.bashrc

uninstall:
	rm -rf $(PREFIX)/bin/*
