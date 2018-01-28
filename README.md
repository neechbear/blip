[![Build Status](https://travis-ci.org/neechbear/blip.svg?branch=master)](https://travis-ci.org/neechbear/blip)
[![Code Climate](https://codeclimate.com/github/neechbear/blip/badges/gpa.svg)](https://codeclimate.com/github/neechbear/blip)
[![Issue Count](https://codeclimate.com/github/neechbear/blip/badges/issue_count.svg)](https://codeclimate.com/github/neechbear/blip)
[![Pre-release Alpha](https://img.shields.io/badge/status-alpha-ff69b4.svg)](https://nicolaw.uk/blip)

# blip - Bash Library for Indolent Programmers

Programmers are lazy. Good system administrators are _really_ lazy. (Why bother
doing something more than once)?

Unfortunately, due to the fact that Bash doesn't particularly lend itself to
reusable code, it doesn't enjoy the same wealth of shared code available that
you find with Python or Perl.

_"But what about the lazy sysadmin that needs to write a script, where Bash
genuinely is the most appropriate option?"_, I hear you ask! Well, by providing
functions for many common tasks, I'm hoping that `blip` will help fill some of
the gaps for those situations.

```
source /usr/lib/blip.bash
```

Please see the man page `man blip.bash`, [bash.pod for full
documentation](blip.bash.pod) or `/usr/share/doc/blip` directory for code
examples and other useful information.

* <https://nicolaw.uk/blip>
* <https://github.com/neechbear/blip/>
  * <https://github.com/neechbear/blip/releases>
  * <https://launchpad.net/~nicolaw/+archive/ubuntu/blip>
  * <http://ppa.launchpad.net/nicolaw/blip/ubuntu/>
  * <https://raw.githubusercontent.com/neechbear/blip/master/blip.bash>

## Installation

### Ubuntu

On Ubuntu, you can install from my PPA
[ppa:nicolaw/blip](https://launchpad.net/~nicolaw/+archive/ubuntu/blip)
by running the following commands:

```
sudo add-apt-repository ppa:nicolaw/blip
sudo apt-get update
sudo apt-get install blip
```

### Debian

On Debian or other Debian-based distributions, you can
[download the DEB package from GitHub](https://github.com/neechbear/blip/releases)
and install it manually with:

```
curl -o https://github.com/neechbear/blip/releases/download/path/to/blip_pkg.deb
sudo dpkg -i blip_pkg.deb
```

### RedHat, CentOS, Fedora

Similarly for RedHat based distributions you can
[install the RPM package from GitHub](https://github.com/neechbear/blip/releases)
manually with:

```
sudo yum localinstall https://github.com/neechbear/blip/releases/download/path/to/blip_pkg.rpm
```

### Source

_Write instructions for installation from GitHub or source tarball here._

## TODO

* Merge all the other cool and reusable stuff I've written in to this library
  (see pending functionality below).
* Make all the shell scripting comply with a sensible style guide (like Google's
  one at <https://google.github.io/styleguide/shell.xml>).
* Finish writing comprehensive manual page with code examples for each function.
* Finish writing comprehensive unit tests with full code coverage.
* Setup automatic build of release tarballs, Deb and RPM packages upon GitHub
  repository commits (assuming a Travis CI pass of unit tests).
* Maybe create [pkg](https://wiki.archlinux.org/index.php/creating_packages),
  [apk](https://wiki.alpinelinux.org/wiki/Creating_an_Alpine_package) and
  [portage](https://wiki.gentoo.org/wiki/Portage) packages if I get bored.

### Pending Functionality

* Add `get_user_input()` - multi character user input without defaults.
* Add process locking functions.
* Add background daemonisation functions (ewww; ppl should use systemd).
* Add standard logging functions.
* Add syslogging functionality of all process `STDOUT` + `STDERR`.
* Add common array manipulation functions.

## See Also

<https://github.com/akesterson/cmdarg> - A pure bash library to make argument
parsing far less troublesome.

