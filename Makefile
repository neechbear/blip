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
CP = cp
LN = ln
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
DISTDEBTAR := $(name)_$(version).orig.tar.gz
DISTDEB := $(name)-$(version).all.deb

DISTTARGETS := debian/changelog version.mk $(specfile)
TARGETS := $(libname) $(manpage) README.html

all: $(TARGETS)

clean:
	$(RM) $(TARGETS)

veryclean:
	$(RM) $(DISTTARGETS)

distclean:
	$(RM) $(DISTTAR) $(DISTDEB) $(DISTRPM) $(DISTDEBTAR) *.gz *.xz *.dsc *.changes *.build *.rpm *.deb
	$(RM) -r $(builddir)

$(builddir): | $(DISTTARGETS)
	mkdir $(builddir)
	$(CP) -r version.mk $(specfile) $(libname).in Makefile CONTRIBUTORS RPM-GPG-KEY-nicolaw LICENSE *.pod *.md debian/ examples/ tests/ $@/

dist: $(DISTTAR)
$(DISTTAR): $(builddir)
	$(TAR) -vzcf $@ $(builddir)

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
	git checkout $@
	dch -M -v $(version) "blah blah blah"
	#$(srcdir)/gitversion.sh -d .git -p $(name) -S -l deb > $@

$(specfile): $(specfile).in
	$(CP) $< $@
	#$(srcdir)/gitversion.sh -d .git -p $(name) -S -l rpm >> $@

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
ifeq ($(gpgsign),true)
		cd $(builddir) && debuild -sa -us -uc -i -I -k$(gpgkeyid) -S
else
		cd $(builddir) && debuild -sa -us -uc -i -I
endif
	dpkg-deb -I $@
	dpkg-deb -c $@

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
    
.PHONY: all dist test install clean distclean deb rpm vcsinfo

