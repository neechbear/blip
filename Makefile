#
# MIT License
#
# Copyright (c) 2016, 2017, 2018 Nicola Worthington <nicolaw@tfb.net>.
#

name := blip
libname := $(name).bash
manpage := $(libname).3
specfile := $(name).spec

SHELL = /bin/sh
SED = sed
GPG = gpg
GREP = grep
TAR = tar
MV = mv
CP = cp
LN = ln
TR = tr
INSTALL = install
POD2MAN = pod2man
MARKDOWN = markdown

GIT_DESCRIBE := git describe --long --always --abbrev=4 --match=v* --dirty=~dirty --tags
GIT_VERSION := $(strip $(shell $(GIT_DESCRIBE) 2>/dev/null))
ifeq ($(GIT_VERSION),)
	-include version.mk
endif

comma:= ,
empty:=
space:= $(empty) $(empty)

vcsahead := $(word $(shell echo $$(( $(words $(subst -, ,$(GIT_VERSION))) - 1 )) ),$(subst -, ,$(GIT_VERSION)))
vcstag := $(subst $(space),-,$(wordlist 1,$(shell echo $$(( $(words $(subst -, ,$(GIT_VERSION))) - 2 )) ),$(subst -, ,$(GIT_VERSION))))
vcsshortref := $(firstword $(subst ~, ,$(lastword $(subst -, ,$(GIT_VERSION)))))
vcsdirty := $(findstring ~dirty,$(GIT_VERSION))

version := $(vcstag:v%=%)
versionmajor := $(word 1, $(subst ., ,$(version)))
versionminor := $(word 2, $(subst ., ,$(version)))
versionpatch := $(word 3, $(subst ., ,$(version)))
release := 1

makefile := $(abspath $(lastword $(MAKEFILE_LIST)))
srcdir := $(dir $(makefile))
builddir := $(name)-$(version)

gpgkeyid := 6393F646
gpgsign := $(subst $(gpgkeyid),true,$(findstring $(gpgkeyid),$(shell $(GPG) --list-secret-keys)))

prefix = /usr/local
bindir = $(prefix)/bin
libdir = $(prefix)/lib
sharedir = $(prefix)/share
docsdir = $(sharedir)/doc/blip
mandir = $(sharedir)/man
man3dir = $(mandir)/man3

DISTTAR := $(name)-$(version)$(vcsdirty).tar.gz
DISTRPM := $(name)-$(version)-$(release)$(vcsdirty).noarch.rpm
#DISTDEBTAR := $(name)_$(version)$(shell lsb_release -is | $(TR) 'A-Z' 'a-z')$(release).orig.tar.gz
DISTDEBTAR := $(name)_$(version).orig.tar.gz
DISTDEB := $(name)_$(version)_all.deb

TARGETS := $(libname) $(manpage) README.html

all: $(TARGETS)

clean:
	$(RM) $(TARGETS)

veryclean:
	$(RM) version.mk

distclean: clean
	$(RM) $(DISTTAR) $(DISTDEB) $(DISTRPM) $(DISTDEBTAR) *.gz *.xz *.dsc *.changes *.build *.rpm *.deb
	$(RM) -r $(builddir)

$(builddir): | version.mk
	mkdir $(builddir)
	$(CP) -r version.mk $(specfile) $(libname).in Makefile CONTRIBUTORS RPM-GPG-KEY-nicolaw LICENSE *.pod *.md debian/ examples/ tests/ $@/

release:
	mkdir $@

release/$(version): | release
	mkdir $@

stash: $(DISTTAR) $(DISTRPM) $(DISTDEB) | release/$(version)
	$(CP) -rpv $(name)_$(version)* $(name)-$(version)* release/$(version)

dist: $(DISTTAR) $(DISTRPM) $(DISTDEB)
$(DISTTAR): $(builddir)
	$(TAR) -zcf $@ $(builddir)

$(libname): $(libname).in
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
	git-dch --debian-branch=master --debian-tag="v%(version)s" --id-length=4 --distribution=xenial
#	git-dch --debian-branch=master --debian-tag="v%(version)s" --id-length=4 --distribution=$$(lsb_release -cs)
#	$(srcdir)/gitversion.sh -d .git -p $(name) -S -l deb > $@

# TODO: Fix automated generation of both RPM and DEB changelogs again.
#$(specfile): $(specfile).in
#	$(CP) $< $@
#	#$(srcdir)/gitversion.sh -d .git -p $(name) -S -l rpm >> $@

README.html: README.md
	$(MARKDOWN) $< > $@

$(manpage): $(libname).pod
	$(POD2MAN) \
		--name="$(shell echo $libname | tr A-Z a-z)" \
		--release="$(libname) $(version)" \
		--center="$(libname)" \
		--section=3 \
		--utf8 $< > $@

$(DISTDEBTAR): $(DISTTAR)
	$(LN) -f $< $@

deb: $(DISTDEB)
$(DISTDEB): debian/changelog $(DISTDEBTAR) $(builddir)
	cd $(builddir) && debuild -sa -us -uc -i -I
	dpkg-deb -I $@
	dpkg-deb -c $@
ifeq ($(gpgsign),true)
	echo bacon
	cd $(builddir) && debuild -sa -i -I -k$(gpgkeyid) -S
endif

rpm: $(DISTRPM)
$(DISTRPM): $(specfile) $(DISTTAR)
	rpmbuild -ba "$(specfile)" \
		--define "name $(name)" \
		--define "version $(version)" \
		--define "release $(release)$(vcsdirty)" \
		--define "dirty $(vcsdirty)" \
		$(subst true,--sign,$(gpgsign)) \
		--define "_sourcedir $(srcdir)" \
		--define "_rpmdir $(srcdir)" \
		--define "_build_name_fmt %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm"
	rpm -qpil $@

test: $(libname) $(manpage)
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
	$(INSTALL) -m 0644 $(libname) "$(DESTDIR)$(libdir)"
	$(INSTALL) -m 0644 $(manpage) "$(DESTDIR)$(man3dir)"
	$(INSTALL) -m 0644 README.* "$(DESTDIR)$(docsdir)"
	$(INSTALL) -m 0644 *.pod "$(DESTDIR)$(docsdir)"
	$(INSTALL) -m 0644 tests/* "$(DESTDIR)$(docsdir)/tests"
	$(INSTALL) -m 0644 examples/* "$(DESTDIR)$(docsdir)/examples"
    
.PHONY: all dist test install clean distclean deb rpm vcsinfo stash

