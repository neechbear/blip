#
# MIT License
#
# Copyright (c) 2016, 2017, 2018 Nicola Worthington <nicolaw@tfb.net>.
#

SHELL = /bin/sh
SED = sed
GPG = gpg
GREP = grep
TAR = tar
CP = cp
LN = ln
INSTALL = install
POD2MAN = pod2man
MARKDOWN = markdown

makefile := $(abspath $(lastword $(MAKEFILE_LIST)))
#srcdir := $(notdir $(patsubst %/,%,$(dir $(makefile))))
srcdir := $(dir $(makefile))
builddir := $(srcdir)build

name := blip
LIBNAME := $(name).bash

GIT_DESCRIBE := $(strip $(shell git describe --long --always --dirty=~dirty 2>/dev/null))
WORD_POS := $(shell echo $$(( $(words $(subst -, ,$(GIT_DESCRIBE))) - 1 )) )
TAG_POS := $(shell echo $$(( $(words $(subst -, ,$(GIT_DESCRIBE))) - 2 )) )
COMMITS_AHEAD := $(word $(WORD_POS),$(subst -, ,$(GIT_DESCRIBE)))
GIT_TAG := $(wordlist 1,$(TAG_POS),$(subst -, ,$(GIT_DESCRIBE)))
SCM_REV := $(firstword $(subst ~, ,$(lastword $(subst -, ,$(GIT_DESCRIBE)))))
DIRTY := $(lastword $(subst ~, ,$(GIT_DESCRIBE)))

foo:
	@echo "GIT_TAG=>$(GIT_TAG)<"
	@echo "COMMITS_AHEAD=>$(COMMITS_AHEAD)<"
	@echo "TAG_POS=>$(TAG_POS)<"
	@echo "WORD_POS=>$(WORD_POS)<"
	@echo "DIRTY=>$(DIRTY)<"
	@echo "SCM_REV=>$(SCM_REV)<"
	@echo "GIT_DESCRIBE=>$(GIT_DESCRIBE)<"


# Used to determine if packaging targets should sign their output.
gpgkeyid = "6393F646"
gpgname = "Nicola Worthington"
gpgsign := $(shell $(GPG) --list-secret-keys | $(GREP) $(gpgkeyid) >/dev/null 2>&1 && echo true)

# Read the version from blip.bash (if we've from a distribution archive),
# otherwise try and extract it from VCS tags using gitversion.sh (which is not
# distributed).
# FIXME: Given that we should still keep the Makefile as functional as possible,
# we shouldn't rely on the dist tarball containing pre-made versions of the
# code. We should make this more robust for discovering the version without VCS.
# Either read from a VERSION config file, or look at the directory name?
# *shrugs*
version := $(shell bash -c '{ source $(srcdir)/$(LIBNAME) && echo "$${BLIP_VERSINFO[0]}.$${BLIP_VERSINFO[1]}"; } 2>/dev/null || { eval $$($(srcdir)/gitversion.sh) && echo "$$VERSION_MAJOR.$$VERSION_MINOR"; }')
release := $(shell bash -c '{ source $(srcdir)/$(LIBNAME) && echo "$${BLIP_VERSINFO[2]}"; } 2>/dev/null || { eval $$($(srcdir)/gitversion.sh) && echo "$$VERSION_RELEASE"; }')

vcsshortref := $(shell git rev-parse --short=7 HEAD)
versionmajor := $(word 1, $(subst ., ,$(version)))
versionminor := $(word 2, $(subst ., ,$(version)))
dirty := $(word 5, $(subst -, ,$(shell git describe --dirty=-dirty)))

rpmmacros := $(builddir)/.rpmmacros

DISTTAR := $(name)-$(version)$(dirty).tar.gz
DISTRPM := $(name)-$(version)-$(release)$(dirty).noarch.rpm
DISTDEBTAR := $(builddir)/$(name)_$(version).orig.tar.gz
DISTDEB := $(builddir)/$(name)-$(version).all.deb

TARGETS := $(LIBNAME) $(name).bash.3 $(name).spec README.html debian/changelog

prefix = /usr/local
bindir = $(prefix)/bin
libdir = $(prefix)/lib
sharedir = $(prefix)/share
docsdir = $(sharedir)/doc/blip
mandir = $(sharedir)/man
man3dir = $(mandir)/man3

all: $(TARGETS)

clean:
	$(RM) $(TARGETS)
	$(RM) -r $(builddir)

distclean:
	$(RM) $(DISTTAR) $(DISTDEB) $(DISTRPM) $(DISTDEBTAR)

$(builddir)/$(name)-$(version): | $(builddir) $(TARGETS)
	mkdir $(builddir)/$(name)-$(version)
	$(CP) -r $(TARGETS) Makefile CONTRIBUTORS RPM-GPG-KEY-nicolaw LICENSE *.pod *.md debian/ examples/ tests/ *.in $@/

dist: $(DISTTAR)
$(DISTTAR): $(builddir)/$(name)-$(version)
	$(TAR) -zcf $@ -C $(builddir)/ $(name)-$(version)/

$(builddir):
	mkdir $(builddir)

$(LIBNAME): $(LIBNAME).in
	$(SED) -e "s/@VERSION_MAJOR@/$(versionmajor)/g" \
				 -e "s/@VERSION_MINOR@/$(versionminor)/g" \
				 -e "s/@VERSION_RELEASE@/$(release)/g" \
				 -e "s/@VERSION_TAG@/$(vcsshortref)$(dirty)/g" \
				 $< > $@

debian/changelog:
	$(srcdir)/gitversion.sh -d .git -p $(name) -S -l deb > $@

$(name).spec: $(name).spec.in
	$(CP) $< $@
	$(srcdir)/gitversion.sh -d .git -p $(name) -S -l rpm >> $@

README.html: README.md
	$(MARKDOWN) $< > $@

$(name).bash.3: $(name).bash.pod
	$(POD2MAN) \
		--name="$(shell echo $LIBNAME | tr A-Z a-z)" \
		--release="$(LIBNAME) $(version)" \
		--center="$(LIBNAME)" \
		--section=3 \
		--utf8 $< > $@

$(DISTDEBTAR): $(DISTTAR) $(builddir)
	$(LN) -f $< $@

deb: $(DISTDEB)
$(DISTDEB): debian/changelog $(DISTDEBTAR) $(builddir)/$(name)-$(version)
	cd $(builddir)/$(name)-$(version) && debuild -sa -us -uc -i -I
	dpkg-deb -I $@
	dpkg-deb -c $@
	#  _debuild "$release_dir"
	#  if [[ -n "${gpg_keyid:-}" ]] ; then
	#    _debuild "$release_dir/deb-src" "-k${gpg_keyid} -S"
	#  fi
	#"-k(gpgkeyid) -S"
	#	$(subst true,--sign,$(gpgsign))

$(rpmmacros): $(builddir)
	echo "%_signature gpg" > $@
	echo "%_gpg_name $(gpgname)" >> $@
	echo "%_gpgbin /usr/bin/gpg" >> $@

rpm: $(DISTRPM)
$(DISTRPM): $(name).spec $(DISTTAR) $(rpmmacros)
	#	--macros "$(rpmmacros)"
	rpmbuild -ba "$(name).spec" \
		--define "name $(name)" \
		--define "version $(version)" \
		--define "release $(release)$(dirty)" \
		--define "dirty $(dirty)" \
		$(subst true,--sign,$(gpgsign)) \
		--define "_sourcedir $(srcdir)" \
		--define "_rpmdir $(srcdir)" \
		--define "_build_name_fmt %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm"
	#rpm -qlpiv $@

test: $(LIBNAME) $(LIBNAME).3
	@bash tests/tests.sh
	@bash -c 'if type -P bash-4.4.0-1 ; then bash-4.4.0-1 tests/tests.sh ; fi'
	@bash -c 'if type -P bash-4.3.0-1 ; then bash-4.3.0-1 tests/tests.sh ; fi'
	@bash -c 'if type -P bash-4.2.0-1 ; then bash-4.2.0-1 tests/tests.sh ; fi'
	@bash -c 'if type -P bash-4.1.0-1 ; then bash-4.1.0-1 tests/tests.sh ; fi'
	@bash -c 'if type -P bash-4.0.0-1 ; then bash-4.0.0-1 tests/tests.sh "bash40_nounset_bug_workaround" ; fi'

install:
	$(INSTALL) -m 0755 -d "$(DESTDIR)$(libdir)"
	$(INSTALL) -m 0755 -d "$(DESTDIR)$(man3dir)"
	$(INSTALL) -m 0755 -d "$(DESTDIR)$(docsdir)/tests"
	$(INSTALL) -m 0755 -d "$(DESTDIR)$(docsdir)/examples"
	$(INSTALL) -m 0644 blip.bash "$(DESTDIR)$(libdir)"
	$(INSTALL) -m 0644 blip.bash.3 "$(DESTDIR)$(man3dir)"
	$(INSTALL) -m 0644 README.* "$(DESTDIR)$(docsdir)"
	$(INSTALL) -m 0644 *.pod "$(DESTDIR)$(docsdir)"
	$(INSTALL) -m 0644 tests/* "$(DESTDIR)$(docsdir)/tests"
	$(INSTALL) -m 0644 examples/* "$(DESTDIR)$(docsdir)/examples"
    
.PHONY: all dist test install clean distclean deb rpm

