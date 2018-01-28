#
# MIT License
#
# Copyright (c) 2016, 2017, 2018 Nicola Worthington <nicolaw@tfb.net>.
#

prefix = /usr/local
bindir = $(prefix)/bin
libdir = $(prefix)/lib
sharedir = $(prefix)/share
docsdir = $(sharedir)/doc/blip
mandir = $(sharedir)/man
man3dir = $(mandir)/man3

all:
	@echo 'Please use "install" target to install blip.'
	@echo '  make install prefix=/usr'
	@echo '  make install prefix=/usr DESTDIR="$$HOME/build"'

test:
	@bash tests/tests.sh
	@bash -c 'if type -P bash-4.4.0-1 ; then bash-4.4.0-1 tests/tests.sh ; fi'
	@bash -c 'if type -P bash-4.3.0-1 ; then bash-4.3.0-1 tests/tests.sh ; fi'
	@bash -c 'if type -P bash-4.2.0-1 ; then bash-4.2.0-1 tests/tests.sh ; fi'
	@bash -c 'if type -P bash-4.1.0-1 ; then bash-4.1.0-1 tests/tests.sh ; fi'
	@bash -c 'if type -P bash-4.0.0-1 ; then bash-4.0.0-1 tests/tests.sh "bash40_nounset_bug_workaround" ; fi'

install:
	install -m 0755 -d "$(DESTDIR)$(libdir)"
	install -m 0755 -d "$(DESTDIR)$(man3dir)"
	install -m 0755 -d "$(DESTDIR)$(docsdir)/tests"
	install -m 0755 -d "$(DESTDIR)$(docsdir)/examples"
	install -m 0644 blip.bash "$(DESTDIR)$(libdir)"
	install -m 0644 blip.bash.3 "$(DESTDIR)$(man3dir)"
	install -m 0644 README.* "$(DESTDIR)$(docsdir)"
	install -m 0644 *.pod "$(DESTDIR)$(docsdir)"
	install -m 0644 tests/* "$(DESTDIR)$(docsdir)/tests"
	install -m 0644 examples/* "$(DESTDIR)$(docsdir)/examples"
    
.PHONY: all test install

