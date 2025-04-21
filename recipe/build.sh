#!/bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .
autoreconf -vfi

declare -a _xtra_configure_args
# sshkey.c: In function 'sshkey_set_filename':
# sshkey.c:3713:1: sorry, unimplemented: '-fzero-call-used-regs' not supported on this target
#  3713 | }
#       | ^
# There have been multiple attempts upstream to resolve this in m4/openssh.m4
# See also: https://github.com/openwrt/packages/issues/24268
if [[ "$target_platform" == "linux-ppc64le" ]]; then
  _xtra_configure_args+=(--with-cflags-after=-fzero-call-used-regs=skip)
fi
./configure \
  --with-libedit \
  --prefix=$PREFIX \
  --with-zlib=$PREFIX \
  --with-ssl-dir=$PREFIX \
  --with-kerberos5=$PREFIX \
  --sbindir=$PREFIX/bin \
  --with-security-key-builtin \
  "${_xtra_configure_args[@]}"

make -j$CPU_COUNT
# make install generate keys for the host which is not what we want
make install-nokeys
