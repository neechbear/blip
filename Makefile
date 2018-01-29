#
# MIT License
#
# Copyright (c) 2016, 2017, 2018 Nicola Worthington <nicolaw@tfb.net>.
#

SHELL = /bin/sh
SED = sed
GPG = gpg
GREP = grep

name = blip
version = 99.99
release = 1
gpgkeyid = "6393F646"
gpgname = "Nicola Worthington"

gpgsign = $(shell $(GPG) --list-secret-keys | $(GREP) $(gpgkeyid) >/dev/null 2>&1 && echo true)
vcsshortref = $(shell git rev-parse --short=7 HEAD)
versionminor = $(word 1, $(subst ., ,$(version)))
versionmajor = $(word 2, $(subst ., ,$(version)))
dirty = 

LIBNAME = $(name).bash
DISTRPM = $(name)-$(version)$(dirty).noarch.rpm
DISTDEB = $(name)-$(version)$(dirty).all.deb
DISTTAR = $(name)-$(version)$(dirty).tar.gz

makefile =  $(abspath $(lastword $(MAKEFILE_LIST)))
#srcdir = $(notdir $(patsubst %/,%,$(dir $(makefile))))
srcdir = $(dir $(makefile))
builddir = $(srcdir)/build

TARGETS = $(LIBNAME) $(name).bash.3 $(name).spec README.html debian/changelog

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
	$(RM) $(DISTTAR) $(DISTDEB) $(DISTRPM)

dist: $(DISTTAR)
$(DISTTAR): $(TARGETS) Makefile CONTRIBUTORS RPM-GPG-KEY-nicolaw LICENSE $(wildcard *.pod) $(wildcard *.md) $(wildcard debian/*)
	tar -zcvf $@ $^

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
	cp $< $@
	$(srcdir)/gitversion.sh -d .git -p $(name) -S -l rpm >> $@

README.html: README.md
	markdown $< > $@

$(name).bash.3: $(name).bash.pod
	pod2man \
		--name="$(shell echo $LIBNAME | tr A-Z a-z)" \
		--release="$(LIBNAME) $(version)" \
		--center="$(LIBNAME)" \
		--section=3 \
		--utf8 $< > $@

.rpmmacros:
	echo "%_signature gpg" > $@
	echo "%_gpg_name $(gpgname)" >> $@
	echo "%_gpgbin /usr/bin/gpg" >> $@

rpm: $(DISTRPM)
$(DISTRPM): $(name).spec $(DISTTAR)
	rpmbuild -ba "$(name).spec" \
		--define "name $(name)" \
		--define "version $(version)" \
		--define "release $(release)$(dirty)" \
		$(subst true,--sign,$(gpgsign)) \
		--define "_sourcedir $(srcdir)" \
		--define "_rpmdir $(srcdir)" \
		--define "_build_name_fmt %%{NAME}-%%{VERSION}-%%{RELEASE}$(dirty).%%{ARCH}.rpm"
	rpm -qlpiv $@

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
    
.PHONY: all dist test install clean distclean deb rpm

#    declare debian_orig_tar="$build_base/${tarball%.tar.gz}.orig.tar.gz"
#    debian_orig_tar="${debian_orig_tar//-/_}"
#    cp ${verbose:+-v} "$build_base/$tarball" "$debian_orig_tar"
#    debuild -sa ${debuild_extra_args:- -us -uc}
#
#    mv ${verbose:+-v} -- \
#      "$build_base"/*.{dsc,changes,build,debian.tar.gz,orig.tar.gz} \
#      "$release_dir"
#
#      dpkg-deb -I "$release_dir/${pkg}_${VERSION}${DIRTY_SUFFIX:+$DIRTY_SUFFIX}_all.deb"
#      dpkg-deb -c "$release_dir/${pkg}_${VERSION}${DIRTY_SUFFIX:+$DIRTY_SUFFIX}_all.deb"
#
#  _debuild "$release_dir"
#  if [[ -n "${gpg_keyid:-}" ]] ; then
#    _debuild "$release_dir/deb-src" "-k${gpg_keyid} -S"
#  fi
#
#_build () {
#  # Copy files in to build directory.
#  rsync -a ${verbose:+-v} \
#    --exclude=".*" --exclude="build/" --exclude="release/" \
#    --exclude="gitversion.sh" --exclude="build.sh" \
#    "${base%/}/" "${build_dir%}/"
#
#
#  # Create release tarball of resulting build directory.
#  tar -C "$build_base" ${verbose:+-v} -zcf "$build_base/$tarball" "${build_dir##*/}/"
#  cp ${verbose:+-v} "$build_base/$tarball" "$release_dir"
#}
#
#  declare -g pkg="blip"
#  eval "$("$base/gitversion.sh" -d "$base/.git" -p "$pkg" -S)"
#  declare -g build_base="$base/build"
#  declare -g build_dir="$build_base/${pkg}-${VERSION_MAJOR}.${VERSION_MINOR}${VERSION_POINT:+$VERSION_POINT}"
#  declare -g release_dir="$base/release/${pkg}-${VERSION}${VERSION_POINT:+$VERSION_POINT}"
#  declare -g tarball="${pkg}-${VERSION_MAJOR}.${VERSION_MINOR}.tar.gz"
#
#  if [[ "$(hostid)" = "007f0101" && "$(id -un)" = "nicolaw" ]] ; then
#    # Sign with the authors key.
#    declare -g gpg_keyid="6393F646"
#    declare -g gpg_name="Nicola Worthington"
#  fi
#
