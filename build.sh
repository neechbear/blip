#!/bin/bash
#
# MIT License
#
# Copyright (c) 2016 Nicola Worthington
#

set -ueo pipefail
declare -g verbose
if [[ $- =~ [vx] ]] ; then verbose=1 ; fi
shopt -s checkwinsize
umask 0077

_build_deb_packages () {
  if ! type -P debuild >/dev/null 2>&1 ; then
    return 0
  fi

  _debuild () {
    declare release_dir="$1"
    declare debuild_extra_args="${2:-}"
    mkdir -p ${verbose:+-v} "$release_dir"

    declare debian_orig_tar="$build_base/${tarball%.tar.gz}.orig.tar.gz"
    debian_orig_tar="${debian_orig_tar//-/_}"
    cp ${verbose:+-v} "$build_base/$tarball" "$debian_orig_tar"

    pushd "$build_dir"
    debuild -sa ${debuild_extra_args:- -us -uc}
    popd

    mv ${verbose:+-v} -- \
      "$build_base"/*.{dsc,changes,build,debian.tar.gz,orig.tar.gz} \
      "$release_dir"

    if stat -t "$build_base"/*.deb >/dev/null 2>&1 ; then
      mv ${verbose:+-v} -- "$build_base"/*.deb "$release_dir"
      dpkg-deb -I "$release_dir/${pkg}_${VERSION}${DIRTY_SUFFIX:+$DIRTY_SUFFIX}_all.deb"
      dpkg-deb -c "$release_dir/${pkg}_${VERSION}${DIRTY_SUFFIX:+$DIRTY_SUFFIX}_all.deb"
    fi
  }

  _debuild "$release_dir"
  if [[ -n "${gpg_keyid:-}" ]] ; then
    _debuild "$release_dir/deb-src" "-k${gpg_keyid} -S"
  fi
}

_build_rpm_packages () {
  if ! type -P rpmbuild >/dev/null 2>&1 ; then
    return 0
  fi

  if [[ -n "${gpg_keyid:-}" && -n "${gpg_name:-}" ]] ; then
    while read -r line ; do
      if ! grep -q "^$line$" ~/.rpmmacros ; then
        echo "$line" >> ~/.rpmmacros
      fi
    done <<RPMMACROS
%_signature gpg
%_gpg_name $gpg_name
%_gpgbin /usr/bin/gpg
RPMMACROS
  fi

  rpmbuild -ba "$build_dir/${pkg}.spec" \
    ${gpg_keyid:+--sign} \
    --define "name $pkg" \
    --define "version $VERSION_MAJOR.$VERSION_MINOR${VERSION_POINT:+.$VERSION_POINT}" \
    --define "release $VERSION_RELEASE" \
    --define "_sourcedir $build_base" \
    --define "_rpmdir $release_dir" \
    --define "_build_name_fmt %%{NAME}-%%{VERSION}-%%{RELEASE}${DIRTY_SUFFIX:+$DIRTY_SUFFIX}.%%{ARCH}.rpm"

  rpm -qlpi ${verbose:+-v} \
    "$release_dir/${pkg}-${VERSION}${DIRTY_SUFFIX:+$DIRTY_SUFFIX}.noarch.rpm"
}

_build () {
  # Copy files in to build directory.
  rsync -a ${verbose:+-v} \
    --exclude=".*" --exclude="build/" --exclude="release/" \
    --exclude="gitversion.sh" --exclude="build.sh" \
    "${base%/}/" "${build_dir%}/"

  # Macro substitution of version information.
  sed -i -e "s/@VERSION_MAJOR@/$VERSION_MAJOR/g" "${build_dir%}/${pkg}.bash.in"
  sed -i -e "s/@VERSION_MINOR@/$VERSION_MINOR/g" "${build_dir%}/${pkg}.bash.in"
  sed -i -e "s/@VERSION_RELEASE@/$VERSION_RELEASE/g" "${build_dir%}/${pkg}.bash.in"
  sed -i -e "s/@VERSION_TAG@/$TAG_SHA1_SHORT${DIRTY_SUFFIX:+$DIRTY_SUFFIX}/g" "${build_dir%}/${pkg}.bash.in"
  mv ${verbose:+-v} "${build_dir%}/${pkg}.bash.in" "${build_dir%}/${pkg}.bash"

  # Dynamically update RPM and DEB package changelogs.
  "$base/gitversion.sh" -d "$base/.git" -p "$pkg" -S -l "deb" \
    > "${build_dir%}/debian/changelog"
  "$base/gitversion.sh" -d "$base/.git" -p "$pkg" -S -l "rpm" \
    >> "${build_dir%}/${pkg}.spec.in"
  mv ${verbose:+-v} "${build_dir%}/${pkg}.spec.in" "${build_dir%}/${pkg}.spec"

  # Generate some Groff man pages from the POD source.
  pod2man \
    --name="BLIP.BASH" \
    --release="${pkg}.bash $VERSION" \
    --center="${pkg}.bash" \
    --section=3 \
    --utf8 "$build_dir/${pkg}.bash.pod" > "$build_dir/${pkg}.bash.3"

  # Generate an HTML version of the README markdown.
  if type -P markdown >/dev/null 2>&1 ; then
    markdown "$build_dir/README.md" > "$build_dir/README.html"
  fi

  # Create release tarball of resulting build directory.
  tar -C "$build_base" ${verbose:+-v} -zcf "$build_base/$tarball" "${build_dir##*/}/"
  cp ${verbose:+-v} "$build_base/$tarball" "$release_dir"
}

main () {
  declare base
  base="$(readlink -f "${BASH_SOURCE[0]%/*}")"

  # Gather information and declare variables first.
  declare -g pkg="blip"
  eval "$("$base/gitversion.sh" -d "$base/.git" -p "$pkg" -S)"
  declare -g build_base="$base/build"
  declare -g build_dir="$build_base/${pkg}-${VERSION_MAJOR}.${VERSION_MINOR}${VERSION_POINT:+$VERSION_POINT}"
  declare -g release_dir="$base/release/${pkg}-${VERSION}${VERSION_POINT:+$VERSION_POINT}"
  declare -g tarball="${pkg}-${VERSION_MAJOR}.${VERSION_MINOR}.tar.gz"

  if [[ "$(hostid)" = "007f0101" && "$(id -un)" = "nicolaw" ]] ; then
    # Sign with the authors key.
    declare -g gpg_keyid="6393F646"
    declare -g gpg_name="Nicola Worthington"
  fi

  # Clean, then build the package.
  rm -Rf ${verbose:+-v} --one-file-system --preserve-root "$build_base"
  mkdir -p ${verbose:+-v} "$build_base" "$build_dir" "$release_dir"
  _build
  if [[ -n "${TESTONLY:-}" ]] ; then
    (
      pushd "$build_dir"
      if [[ "$TESTONLY" == "test.sh" ]] ; then
        tests/tests.sh
      else
        make test
      fi
      popd
    )
  else
    _build_deb_packages
    _build_rpm_packages
    ls --color -Rla "$release_dir"
  fi
}

main "$@"

