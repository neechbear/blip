#!/usr/bin/env bash
#
# MIT License
#
# Copyright (c) 2016, 2017, 2018 Nicola Worthington
#

# TODO: This script is over engineered and broken. It needs to be replaced as a
#       basic wrapper around git-dch, but still generate an RPM changelog. All
#       the other functionality can be thrown away.

set -ueo pipefail
shopt -s nocasematch

git () {
  command git --git-dir="${GIT_DIR:-.git}" "$@"
}

parse_args () {
  # TODO(nicolaw): This is fragile; maybe improve with getopt/getops?
  while [[ $# -ge 1 ]] ; do
    declare key="${1:-}"
    case "$key" in
      -d|--git-dir)   printf 'GIT_DIR="%s"\n' "${2:-.git}"; shift ;;
      -p|--pkg-name)  printf 'PKG_NAME="%s"\n' "${2:-}"; shift ;;
      -k|--key)       printf 'PRINT_KEY="%s"\n' "${2:-}"; shift ;;
      -S|--no-source) printf 'NO_SOURCE="1"\n' ;;
      -b|--branch)    printf 'BRANCH="%s"\n' "${2:-master}"; shift ;;
      -c|--commit)    printf 'COMMIT="%s"\n' "${2:-HEAD}"; shift ;;
      -t|--tag)       printf 'TAG="%s"\n' "${2:-}"; shift ;;
      -l|--log)       printf 'LOG="%s"\n' "${2:-changelog}"; shift ;;
      -O|--os-name)   printf 'OS_NAME="%s"\n' "${2:-}"; shift ;;
      -D|--os-dist)   printf 'OS_DISTRIBUTION="%s"\n' "${2:-}"; shift ;;
      -V|--os-ver)    printf 'OS_VERSION="%s"\n' "${2:-}"; shift ;;
      -v|--version)   printf 'PRINT_VERSION="!"\n' ;;
      -h|--help)      printf 'PRINT_HELP="1"\n' ;;
    esac
    shift
  done
}

print_version () {
  echo "https://media.giphy.com/media/101qkTeAqyMbio/giphy.gif"
}

print_usage () {
  cat <<EOM
Syntax: ${0#*/} [options]
  -d, --git-dir=DIR    Specify .git repository (defaults to .git)
  -p, --pkg-name=NAME  Specify the package name (derive from repo path/origin)
  -k, --key=KEY        Only print output value of specific KEY
  -S, --no-source      Do not attempt to discover upstream source
  -b, --branch=BRANCH  Specify branch (defaults to master)
  -c, --commit=ID      Specify last git commit-ish like ID to work up to
  -t, --tag=TAG        Specify git tag to work from
  -l, --log=FORMAT     Output changelog in a particular format (deb, rpm)
  -O, --os-name=NAME   Overload OS detection, explicitly providing OS_NAME
  -D, --os-dist=DIST   Overload OS detection, explicitly providing OS_DISTRIB
  -V, --os-ver=VERSION Overload OS detection, explicitly providing OS_VERSION
  -h, --help           Display this help message
EOM
}

os_name () {
  uname -s
}

os_distribution () {
  local os_name="${1:-}"
  if [[ -r /etc/lsb-release ]] ; then
    eval "$(egrep "^DISTRIB_ID=.*" "/etc/lsb-release")"
  fi
  if [[ -n "$DISTRIB_ID" ]] ; then
    echo "$DISTRIB_ID"
  elif [[ -e /etc/centos-release ]] ; then
    echo "CentOS"
  elif [[ -e /etc/redhat-release ]] ; then
    echo "RHEL"
  elif [[ -e /etc/ubuntu-release ]] ; then
    echo "Ubuntu"
  elif [[ -e /etc/debian-release ]] ; then
    echo "Debian"
  fi
  if [[ "$os_name" == "Darwin" ]] ; then
    sw_vers -productName
  fi
}

os_codename () {
  local os_name="${1:-}"
  if [[ -r /etc/lsb-release ]] ; then
    eval "$(egrep "^DISTRIB_CODENAME=.*" "/etc/lsb-release")"
  fi
  if [[ -n "$DISTRIB_CODENAME" ]] ; then
    echo "$DISTRIB_CODENAME"
  fi
}

os_version () {
  local os_name="${1:-}"
  if [[ -r /etc/lsb-release ]] ; then
    eval "$(egrep "^DISTRIB_RELEASE=.*" "/etc/lsb-release")"
  fi
  if [[ -n "$DISTRIB_RELEASE" ]] ; then
    echo "$DISTRIB_RELEASE"
  elif [[ "$os_name" == "Darwin" ]] ; then
    sw_vers -productVersion
  else
    uname -r
  fi
}

os_pkg_suffix () {
  local os="${1:-}"
  local ver="${2:-}"
  case "$os" in
    RedHat*|RHEL|CentOS*) echo "el${ver%%.*}" ;;
    Fedora*) echo  "fc${ver%%.*}" ;;
    Ubuntu*) echo "ubuntu" ;;
  esac
}

git_branch () {
  git branch | grep '^\*\s*.*' | cut -d ' ' -f 2-
}

git_tag () {
  local commit="${1:-$COMMIT}"
  git describe --tags --abbrev=0 --first-parent --match=v* "${commit:-HEAD}"
}

git_tag_bash_rematch () {
  [[ "${1:-}" =~ ^v(([0-9]+)\.([0-9]+)(\.([0-9]+))?(-([0-9]+))?)$ ]]
}

git_longid () {
  local commit="${1:-$COMMIT}"
  git rev-list -n 1 "${commit:-HEAD}"
}

git_shortid () {
  local commit="${1:-$COMMIT}"
  git rev-parse --short "${commit:-HEAD}"
}

git_isdirty () {
  [[ "$(git diff --shortstat 2> /dev/null | tail -n1)" != "" ]] && echo "true"
}

git_source () {
  git remote show origin 2>/dev/null \
    | grep "Fetch URL" | cut -d : -f 2- | cut -d ' ' -f 2-
}

changelog () {
  local logtype="${1:-}"
  local first="${2:-}"
  local last="${3:-}"
  local annotation="${4:-}"

  if [[ -z "$first" && -z "$last" ]] ; then
    local output=""
    while read -r last annotation; do
      printf "\nlogtype=>%s< first=>%s< last=>%s< annotation=>%s<\n" \
        "$logtype" "$first" "$last" "$annotation" >&2
      output="$(changelog "$logtype" "$first" "$last" "$annotation")

$output"
      first="$last"
    done < <(
      git tag -l -n1 v*
      if [[ "$(git_longid "$(git_tag)")" != "$(git_longid "HEAD")" ]] ; then
        echo "HEAD"
      fi
    )
    echo "$output"

  else
    local tag="$last"
    if [[ "$tag" == "HEAD" ]] ; then
      tag="$first"
      if [[ -n "${DIRTY_SUFFIX:-}" ]] ; then
        local dirty_suffix="$DIRTY_SUFFIX"
      fi
    fi

    if git_tag_bash_rematch "$tag" ; then
      local version="${BASH_REMATCH[1]}"
      local version_major="${BASH_REMATCH[2]}"
      local version_minor="${BASH_REMATCH[3]}"
      local version_point="${BASH_REMATCH[5]}"
      local version_release="${BASH_REMATCH[7]}"
    else
      >&2 echo "Unable to extract version information for git tag $tag; aborting!"
      exit 99
    fi

    case "${logtype:-}" in
      debian|ubuntu|dch|deb)
        local urgency="low"
        local os_distribution="${OS_CODENAME:-}"
        os_distribution="${os_distribution,,}"

        if [[ "$annotation" =~ urgency=([^[:space:]]+) ]] ; then
          urgency="${BASH_REMATCH[1],,}"
        fi
        if [[ -n "${dirty_suffix:-}" ]] ; then
          os_distribution="UNRELEASED"
        fi

        printf '%s (%s) %s; urgency=%s\n\n' \
          "$PKG_NAME" "$version${dirty_suffix:-}" "$os_distribution" "$urgency"
        git log --branches="${BRANCH}" --format="format:  * %s" "${first:+$first..}${last}" | cat
        git log --branches="${BRANCH}" -1 \
          --format="format:%n%n -- %aN <%aE>  %aD" \
          "${last}" | cat
        ;;

      redhat|rhel|centos|fedora|rpm)
        git log --branches="${BRANCH}" -1 \
          --format="format:* @%ad@ %aN <%aE> - $version${dirty_suffix:-}%n" \
          --date=raw \
          "${last}" \
            | perl -MPOSIX=strftime -pe \
            's/^\* @([0-9]+) [\+-]?[0-9]{4}@ /* @{[strftime("%a %b %d %Y",localtime($1))]} /'
          # Custom date formats are not supported in Git 1.x :-(
          #--date=format:"%a %b %d %Y" \
        git log --branches="${BRANCH}" \
          --format="format:- %s" \
          "${first:+$first..}${last}" | cat
        ;;

      *%[a-zA-Z]*)
        git log --branches="${BRANCHES}" \
          ${logtype:+--format="format:$logtype"} \
          "${first:+$first..}${last}" | cat
        ;;
    esac
  fi
}

main () {
  eval "$(parse_args "$@")"
  if [[ $? -gt 0 || -n "${PRINT_HELP:-}" ]] ; then
    print_usage
    return 0
  elif [[ -n "${PRINT_VERSION:-}" ]] ; then
    print_version
    return 64
  fi

  GIT_DIR="${GIT_DIR:-.git}"
  GIT_TOPLEVEL="$(git rev-parse --show-toplevel)" 
  BRANCH="${BRANCH:-$(git_branch)}"

  if [[ -z "${NO_SOURCE:-}" ]] ; then
    SOURCE="$(git_source)" || unset SOURCE
  fi

  if [[ -z "${PKG_NAME:-}" && "${SOURCE:-}" =~ /([^/]+)\.git$ ]] ; then
    PKG_NAME="${BASH_REMATCH[1]}"
  elif [[ -z "${PKG_NAME:-}" && -n "${GIT_TOPLEVEL:-}" ]] ; then
    PKG_NAME="${GIT_TOPLEVEL##*/}"
  fi

  COMMIT="${COMMIT:-HEAD}"
  COMMIT_SHA1="$(git_longid "$COMMIT")"
  COMMIT_SHA1_SHORT="$(git_shortid "$COMMIT")"

  if ! TAG="$(git_tag "$COMMIT")" ; then
    exit 98
  fi
  TAG_SHA1="$(git_longid "$TAG")"
  TAG_SHA1_SHORT="$(git_shortid "$TAG")"

  TAG_CHANGES=$(git rev-list "$TAG..$COMMIT" --count)
  DIRTY="$(git_isdirty)" || :
  if [[ -n "$DIRTY" || ${TAG_CHANGES:-0} -gt 0 ]] ; then
    DIRTY_SUFFIX="~devbuild${TAG_CHANGES:-0}"
  fi

  if git_tag_bash_rematch "$TAG" ; then
    VERSION="${BASH_REMATCH[1]}"
    VERSION_MAJOR="${BASH_REMATCH[2]}"
    VERSION_MINOR="${BASH_REMATCH[3]}"
    VERSION_POINT="${BASH_REMATCH[5]}"
    VERSION_RELEASE="${BASH_REMATCH[7]}"
  fi

  # TODO(nicolaw): What about arch etc? This feels flakey.
  if [[ -z "${OS_DISTRIBUTION:-}" && -z "${OS_NAME:-}" && -z "${OS_VERSION:-}" ]] ; then
    OS_NAME="$(os_name)"
    OS_DISTRIBUTION="$(os_distribution "${OS_NAME:-}")"
    OS_CODENAME="$(os_codename "${OS_NAME:-}")"
    OS_VERSION="$(os_version "${OS_NAME:-}")"
  fi
  if [[ -n "${OS_NAME:-}" && -z "${OS_DISTRIBUTION:-}" ]] ; then
    OS_DISTRIBUTION="$OS_NAME"
  fi
  OS_PKG_SUFFIX="$(os_pkg_suffix "${OS_DISTRIBUTION:-}" "${OS_VERSION:-}")"

  if [[ -n "${PRINT_KEY:-}" ]] ; then
    echo "${!PRINT_KEY:-}"

  elif [[ -n "${LOG:-}" ]] ; then
    changelog "$LOG"

  else
    for v in GIT_DIR GIT_TOPLEVEL PKG_NAME DIRTY DIRTY_SUFFIX SOURCE BRANCH \
      COMMIT COMMIT_SHA1 COMMIT_SHA1_SHORT \
      TAG TAG_SHA1 TAG_SHA1_SHORT TAG_CHANGES \
      VERSION VERSION_MAJOR VERSION_MINOR VERSION_POINT VERSION_RELEASE \
      OS_NAME OS_DISTRIBUTION OS_CODENAME OS_VERSION OS_PKG_SUFFIX
    do
      if [[ -n "${!v+defined}" ]] ; then
        printf '%s="%s"\n' "$v" "${!v:-}"
      fi
    done
  fi
}

main "$@"

# git describe --tags --dirty --always 2> /dev/null || echo "dev"
# git tag -u 6393F646 -a v0.3-1 -m 'Initial successful LaunchPad PPA submission' 7947d41
# git config --global user.signingkey "6393F646"
# git --no-pager log v0.3-1..HEAD --pretty --format='%cD,%cn,%ce,%h,"%s","%d"'
# git --no-pager log  --pretty --format='%cD,%cn,%ce,%h,"%s","%d"'
# git tag -l -n9
# git tag -l 


