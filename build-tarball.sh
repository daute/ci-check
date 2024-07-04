#!/bin/sh

# Copyright (C) 2024 Free Software Foundation, Inc.
#
# This file is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# This file is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# This script builds the package.
# Usage: build-tarball.sh PACKAGE
# Its output is a tarball: $package-$version.tar.bz2

package="$1"

set -e

# Fetch sources (uses package 'git').
git clone --depth 1 https://gitlab.com/gnu-clisp/"$package".git
cd "$package"
date=`date --utc --iso-8601 | sed -e 's/-//g'`; sed -i -e "/VERSION_NUMBER=/s/\\([0-9][0-9.]*\\).*/\\1-${date}/" version.sh
make -f Makefile.devel src-distrib
cd ..
mv archives/*/*.tar.bz2 .

# Fetch dependency sources (uses package 'wget').
wget https://ftp.gnu.org/gnu/libsigsegv/libsigsegv-2.14.tar.gz
wget https://alpha.gnu.org/gnu/libffcall/libffcall-2.4.90.tar.gz
