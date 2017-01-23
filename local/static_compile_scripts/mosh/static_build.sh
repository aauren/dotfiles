#!/bin/bash

set -e

INSTALL_DIR="${HOME}/thirdparty-git/mosh/build_install"

GENTOO_REPO="/var/portage/repos/gentoo"
WORK_DIRECTORY="/var/tmp/portage"
PROTOBUF_VERSION=3.1.0
ZLIB_VERSION=1.2.10
NCURSES_VERSION=5.9-r5
PERL_VERSION=5.24.1_rc4
OPENSSL_VERSION=1.0.2j

PROTOBUF_WORK_DIR="${WORK_DIRECTORY}/dev-libs/protobuf-${PROTOBUF_VERSION}/work/protobuf-${PROTOBUF_VERSION}"
ZLIB_WORK_DIR="${WORK_DIRECTORY}/sys-libs/zlib-${ZLIB_VERSION}/work/zlib-${ZLIB_VERSION}"
NCURSES_WORK_DIR="${WORK_DIRECTORY}/sys-libs/ncurses-${NCURSES_VERSION}/work/ncurses-${NCURSES_VERSION%-*}"
PERL_WORK_DIR="${WORK_DIRECTORY}/dev-lang/perl-${PERL_VERSION}/work/perl-${PERL_VERSION/_rc/-RC}"
OPENSSL_WORK_DIR="${WORK_DIRECTORY}/dev-libs/openssl-${OPENSSL_VERSION}/work/openssl-${OPENSSL_VERSION}"
MOSH_WORK_DIR="/home/auren/thirdparty-git/mosh"

build_deps() {
	echo "+++++++++++++++++++++++++++++++++ Making protobuf +++++++++++++++++++++++++++++++++"
	sleep 5
	ebuild "${GENTOO_REPO}/dev-libs/protobuf/protobuf-${PROTOBUF_VERSION}.ebuild" unpack
	pushd "${PROTOBUF_WORK_DIR}"
	./autogen.sh
	./configure --with-pic --enable-static --disable-shared --prefix="${INSTALL_DIR}"
	make && make install
	popd

	echo "+++++++++++++++++++++++++++++++++ Making zlib     +++++++++++++++++++++++++++++++++"
	sleep 5
	ebuild "${GENTOO_REPO}/sys-libs/zlib/zlib-${ZLIB_VERSION}.ebuild" unpack
	pushd "${ZLIB_WORK_DIR}"
	./configure --static --prefix="${INSTALL_DIR}"
	make && make install
	popd

	echo "+++++++++++++++++++++++++++++++++ Making ncurses  +++++++++++++++++++++++++++++++++"
	sleep 5
	ebuild "${GENTOO_REPO}/sys-libs/ncurses/ncurses-${NCURSES_VERSION}.ebuild" unpack
	pushd "${NCURSES_WORK_DIR}"
	./configure --prefix="${INSTALL_DIR}" --without-shared
	make && make install
	popd

	echo "+++++++++++++++++++++++++++++++++ Making perl     +++++++++++++++++++++++++++++++++"
	sleep 5
	ebuild "${GENTOO_REPO}/dev-lang/perl/perl-${PERL_VERSION}.ebuild" unpack
	pushd "${PERL_WORK_DIR}"
	./Configure -des -Dprefix="${INSTALL_DIR}"
	make && make install
	popd

	echo "+++++++++++++++++++++++++++++++++ Making openssl  +++++++++++++++++++++++++++++++++"
	sleep 5
	ebuild "${GENTOO_REPO}/dev-libs/openssl/openssl-${OPENSSL_VERSION}.ebuild" unpack
	pushd "${OPENSSL_WORK_DIR}"
	./config --prefix="${INSTALL_DIR}" no-shared
	make && make install
	popd
}

build_deps

echo "+++++++++++++++++++++++++++++++++ Making mosh     +++++++++++++++++++++++++++++++++++++"
sleep 5
pushd "${MOSH_WORK_DIR}"
./autogen.sh
LDFLAGS="-I${INSTALL_DIR}/include -I${INSTALL_DIR}/include/ncursesw -L${INSTALL_DIR}/lib -L${INSTALL_DIR}/lib -lz -ldl -lncurses -static" \
	./configure --prefix="${INSTALL_DIR}"
make && make install
popd
