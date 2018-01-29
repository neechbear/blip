Summary: Bash Library for Indolent Programmers
Name: %{name}
Version: %{version}
Release: %{release}%{?dist}
License: MIT
Group: Development/Library
BuildArch: noarch
Prefix: /usr
Prefix: /usr/lib
Prefix: /usr/share/man
Source0: %{name}-%{version}%{?dirty}.tar.gz
URL: https://nicolaw.uk/blip
Packager: Nicola Worthington <nicolaw@tfb.net>

%description
Common functions library for Bash 4.

%clean
rm -rf --one-file-system --preserve-root "%{buildroot}"

%prep
%setup -q

%build
make

%install
make install DESTDIR="%{buildroot}" prefix=/usr

%files
/usr/lib/blip.bash
/usr/share/man/man3/blip.bash.3.gz
%docdir /usr/share/doc/blip
/usr/share/doc/blip

%changelog
