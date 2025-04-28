#!/bin/bash

# Taken from the gist created by feiskyer: https://gist.github.com/feiskyer/1911c365014d9577dd765d5a7eb5aa89

export SOCAT_VERSION=1.8.0.3
export NCURSES_VERSION=6.5
export READLINE_VERSION=8.2.13
export OPENSSL_VERSION=3.5.0

function build_ncurses() {
	cd /build

	# Download
	curl -LO https://ftp.gnu.org/pub/gnu/ncurses/ncurses-${NCURSES_VERSION}.tar.gz
	tar zxvf ncurses-${NCURSES_VERSION}.tar.gz
	cd ncurses-${NCURSES_VERSION}

	# Build
	CC='/usr/bin/x86_64-alpine-linux-musl-gcc -static' CFLAGS='-fPIC' ./configure \
		--disable-shared \
		--enable-static || return 1
}

function build_readline() {
	cd /build

	# Download
	curl -LO https://ftp.gnu.org/gnu/readline/readline-${READLINE_VERSION}.tar.gz
	tar xzvf readline-${READLINE_VERSION}.tar.gz
	cd readline-${READLINE_VERSION}
	ln -s /build/readline-${READLINE_VERSION} /build/readline

	# Build
	CC='/usr/bin/x86_64-alpine-linux-musl-gcc -static' \
		CFLAGS='-fPIC' \
		./configure --disable-shared --enable-static
	make -j20 || return 1
	make install-static || return 1
}

function build_openssl() {
	cd /build

	# Download
	curl -LO https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
	tar zxvf openssl-${OPENSSL_VERSION}.tar.gz
	cd openssl-${OPENSSL_VERSION}

	# Configure
	CC='/usr/bin/x86_64-alpine-linux-musl-gcc -static' \
		./Configure no-pic no-shared linux-x86_64

	# Build
	make -j20 || return 1
	echo "** Finished building OpenSSL"
}

function build_socat() {
	cd /build

	# Download
	curl -LO http://www.dest-unreach.org/socat/download/socat-${SOCAT_VERSION}.tar.gz
	tar xzvf socat-${SOCAT_VERSION}.tar.gz
	cd socat-${SOCAT_VERSION}

	# Build
	# NOTE: `NETDB_INTERNAL` is non-POSIX, and thus not defined by MUSL.
	# We define it this way manually.
	CC='/usr/bin/x86_64-alpine-linux-musl-gcc -static' \
		CFLAGS="-fPIC -DWITH_OPENSSL -I/build -I/build/openssl-${OPENSSL_VERSION}/include -I/build/readline-${READLINE_VERSION} -DNETDB_INTERNAL=-1" \
		CPPFLAGS="-DWITH_OPENSSL -I/build -I/build/openssl-${OPENSSL_VERSION}/include -I/build/readline -DNETDB_INTERNAL=-1" \
		LDFLAGS="-L/build/readline -L/build/ncurses-${NCURSES_VERSION}/lib -L/build/openssl-${OPENSSL_VERSION}" \
		sc_cv_getprotobynumber_r=2 \
		./configure
	patch -p1 -i ../patches/socat_fix_static.patch
	patch -p1 -i ../patches/socat_fix_getprotobynumber.patch
	make -j20
	strip socat
}

function doit() {
	build_ncurses || exit 1
	build_readline || exit 1
	build_openssl || exit 1
	build_socat || exit 1

	# Copy to output
	if [ -d /output ]
	then
		OUT_DIR=/output
		mkdir -p $OUT_DIR
		cp /build/socat-${SOCAT_VERSION}/socat $OUT_DIR/
		echo "** Finished building socat **"
	else
		echo "** /output does not exist **"
	fi
}

doit
