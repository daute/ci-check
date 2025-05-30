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

# This script builds a tarball of the package on a single platform.
# Usage: build-on.sh PACKAGE CONFIGURE_OPTIONS MAKE

package="$1"
configure_options="$2"
make="$3"
prefix="$4"
prerequisites="$5"

set -x

# building clisp requires this...
ulimit -s 8192

# Build and install the prerequisites.
for prereq in $prerequisites; do
  tar xfz $prereq.tar.gz
  cd $prereq
  # --disable-shared avoids problem 1) with rpath on ELF systems, 2) with DLLs on Windows.
  ./configure $configure_options --disable-shared --prefix="$prefix" > log1 2>&1; rc=$?; cat log1; test $rc = 0 || exit 1
  $make > log2 2>&1; rc=$?; cat log2; test $rc = 0 || exit 1
  $make install > log4 2>&1; rc=$?; cat log4; test $rc = 0 || exit 1
  cd ..
done

# Unpack the tarball.
tarfile=`echo "$package"-*.tar.bz2`
packagedir=`echo "$tarfile" | sed -e 's/\.tar\.bz2$//'`
tar xfj "$tarfile"
cd "$packagedir" || exit 1

mkdir build
cd build

# Configure.
case $prerequisites in
  *libsigsegv*) libsigsegv_options="--with-libsigsegv-prefix=$prefix" ;;
  *)            libsigsegv_options="--ignore-absence-of-libsigsegv" ;;
esac
FORCE_UNSAFE_CONFIGURE=1 ../configure $libsigsegv_options --with-libffcall-prefix="$prefix" $configure_options > log1 2>&1; rc=$?; cat log1; test $rc = 0 || exit 1

# Build.
$make > log2 2>&1; rc=$?; cat log2; test $rc = 0 || exit 1

# Run the tests.
$make check > log3 2>&1; rc=$?; cat log3; test $rc = 0 || exit 1
$make extracheck > log4 2>&1; rc=$?; cat log4; test $rc = 0 || exit 1
$make base-mod-check > log5 2>&1; rc=$?; cat log5; test $rc = 0 || exit 1

cd ..
