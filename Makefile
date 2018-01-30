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

name := blip
LIBNAME := $(name).bash
GIT_DESCRIBE := git describe --long --always --abbrev=4 --match=v* --dirty=~dirty --tags

-include version.mk
ifeq ($(GIT_VERSION),)
	GIT_VERSION := $(strip $(shell $(GIT_DESCRIBE) 2>/dev/null))
endif

comma:= ,
empty:=
space:= $(empty) $(empty)

vcsahead := $(word $(shell echo $$(( $(words $(subst -, ,$(GIT_VERSION))) - 1 )) ),$(subst -, ,$(GIT_VERSION)))
vcstag := $(subst $(space),-,$(wordlist 1,$(shell echo $$(( $(words $(subst -, ,$(GIT_VERSION))) - 2 )) ),$(subst -, ,$(GIT_VERSION))))
vcsshortref := $(firstword $(subst ~, ,$(lastword $(subst -, ,$(GIT_VERSION)))))
vcsdirty := $(lastword $(subst ~, ,$(GIT_VERSION)))

version := $(vcstag:v%=%)
versionmajor := $(word 1, $(subst ., ,$(version)))
versionminor := $(word 2, $(subst ., ,$(version)))
versionpatch := $(word 3, $(subst ., ,$(version)))
release := 1

builddir := $(srcdir)$(name)-$(version)

# Used to determine if packaging targets should sign their output.
gpgkeyid = "6393F646"
gpgname = "Nicola Worthington"
gpgsign := $(shell $(GPG) --list-secret-keys | $(GREP) $(gpgkeyid) >/dev/null 2>&1 && echo true)

#rpmmacros := $(builddir)/.rpmmacros

DISTTAR := $(name)-$(version)$(vcsdirty).tar.gz
DISTRPM := $(name)-$(version)-$(release)$(vcsdirty).noarch.rpm
DISTDEBTAR := $(name)_$(version).orig.tar.gz
DISTDEB := $(name)-$(version).all.deb

TARGETS := $(LIBNAME) $(name).bash.3 README.html
DISTTARGETS := debian/changelog version.mk $(name).spec

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

distclean:
	$(RM) $(DISTTAR) $(DISTDEB) $(DISTRPM) $(DISTDEBTAR) $(DISTTARGETS) *.gz *.xz *.dsc *.changes *.build *.rpm *.deb
	$(RM) -r $(builddir)

$(builddir): | $(DISTTARGETS)
	mkdir $(builddir)
	$(CP) -r $| $(LIBNAME).in Makefile CONTRIBUTORS RPM-GPG-KEY-nicolaw LICENSE *.pod *.md debian/ examples/ tests/ $@/

dist: $(DISTTAR)
$(DISTTAR): $(builddir)
	$(TAR) -zcf $@ $(builddir)

$(LIBNAME): $(LIBNAME).in
	$(SED) -e "s/@VERSION_MAJOR@/$(versionmajor)/g" \
				 -e "s/@VERSION_MINOR@/$(versionminor)/g" \
				 -e "s/@VERSION_PATCH@/$(versionpatch)/g" \
				 -e "s/@VERSION_TAG@/$(vcsshortref)$(vcsdirty)/g" \
				 $< > $@

version.mk:
	echo -n "GIT_VERSION := " > $@
	$(GIT_DESCRIBE) >> $@

vcsinfo:
	@echo "vcsahead=>$(vcsahead)<"
	@echo "vcstag=>$(vcstag)<"
	@echo "vcsshortref=>$(vcsshortref)<"
	@echo "vcsdirty=>$(vcsdirty)<"
	@echo "version=>$(version)<"
	@echo "versionmajor=>$(versionmajor)<"
	@echo "versionminor=>$(versionminor)<"
	@echo "versionpatch=>$(versionpatch)<"
	@echo "release=>$(release)<"

debian/changelog:
	true
	#$(srcdir)/gitversion.sh -d .git -p $(name) -S -l deb > $@

$(name).spec: $(name).spec.in
	$(CP) $< $@
	#$(srcdir)/gitversion.sh -d .git -p $(name) -S -l rpm >> $@

README.html: README.md
	$(MARKDOWN) $< > $@

$(name).bash.3: $(name).bash.pod
	$(POD2MAN) \
		--name="$(shell echo $LIBNAME | tr A-Z a-z)" \
		--release="$(LIBNAME) $(version)" \
		--center="$(LIBNAME)" \
		--section=3 \
		--utf8 $< > $@

$(DISTDEBTAR): $(DISTTAR)
	$(LN) -f $< $@

deb: $(DISTDEB)
$(DISTDEB): debian/changelog $(DISTDEBTAR) $(builddir)
	cd $(builddir) && debuild -sa -us -uc -i -I
	dpkg-deb -I $@
	dpkg-deb -c $@
	#  _debuild "$release_dir"
	#  if [[ -n "${gpg_keyid:-}" ]] ; then
	#    _debuild "$release_dir/deb-src" "-k${gpg_keyid} -S"
	#  fi
	#"-k(gpgkeyid) -S"
	#	$(subst true,--sign,$(gpgsign))

#$(rpmmacros): $(builddir)
#	echo "%_signature gpg" > $@
#	echo "%_gpg_name $(gpgname)" >> $@
#	echo "%_gpgbin /usr/bin/gpg" >> $@

rpm: $(DISTRPM)
#$(DISTRPM): $(name).spec $(DISTTAR) $(rpmmacros)
$(DISTRPM): $(name).spec $(DISTTAR)
	#	--macros "$(rpmmacros)"
	rpmbuild -ba "$(name).spec" \
		--define "name $(name)" \
		--define "version $(version)" \
		--define "release $(release)$(vcsdirty)" \
		--define "dirty $(vcsdirty)" \
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
    
.PHONY: all dist test install clean distclean deb rpm vcsinfo

