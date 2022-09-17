#!/bin/bash

# Taken from the gist created by feiskyer: https://gist.github.com/feiskyer/1911c365014d9577dd765d5a7eb5aa89

export SOCAT_VERSION=1.7.4.3
export NCURSES_VERSION=6.3
export READLINE_VERSION=8.1
export OPENSSL_VERSION=1.1.1q

function build_ncurses() {
	cd /build

	# Download
	curl -LO https://ftp.gnu.org/pub/gnu/ncurses/ncurses-${NCURSES_VERSION}.tar.gz
	tar zxvf ncurses-${NCURSES_VERSION}.tar.gz
	cd ncurses-${NCURSES_VERSION}

	# Build
	CC='/usr/bin/x86_64-alpine-linux-musl-gcc -static' CFLAGS='-fPIC' ./configure \
		--disable-shared \
		--enable-static
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
	make -j4
	make install-static
}

function build_openssl() {
	cd /build

	# Download
	curl -LO https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
	tar zxvf openssl-${OPENSSL_VERSION}.tar.gz
	cd openssl-${OPENSSL_VERSION}

	# Configure
	CC='/usr/bin/x86_64-alpine-linux-musl-gcc -static' \
		CFLAGS='-fPIC' \
		./Configure no-shared linux-x86_64

	# Build
	make -j4
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
	make -j4
	strip socat
}

function doit() {
	build_ncurses
	build_readline
	build_openssl
	build_socat

	# Copy to output
	if [ -d /output ]
	then
		OUT_DIR=/output
		mkdir -p $OUT_DIR
		cp /build/socat-${SOCAT_VERSION}/socat $OUT_DIR/
		echo "** Finished **"
	else
		echo "** /output does not exist **"
	fi
}

doit
