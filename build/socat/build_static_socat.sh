#!/bin/bash

# Taken from the gist created by feiskyer: https://gist.github.com/feiskyer/1911c365014d9577dd765d5a7eb5aa89

export SOCAT_VERSION=1.8.1.3
export OPENSSL_VERSION=4.0.2

# socat's ./configure only wires up readline support if it can actually find a usable readline at
# configure time (see AC_MSG_CHECKING(for usable readline) in configure.ac), and that check never
# succeeded against our statically built copy. `strings` on the resulting binary confirmed no rl_*
# or history_* symbols ever made it in, so xioopen_readline() was always compiled out behind
# `#if WITH_READLINE`. We were building ncurses+readline for nothing this whole time; dropping them
# shrinks the build and doesn't change the shipped binary's behavior at all.

function build_openssl() {
	echo "=================================================== BUILDING OpenSSL ==================================================="
	cd /build

	# Download
	curl -LO https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
	tar zxvf openssl-${OPENSSL_VERSION}.tar.gz
	cd openssl-${OPENSSL_VERSION}

	# Configure
	# We disable a long tail of legacy/niche algorithms (old export ciphers, national/regional
	# algorithms we have no reason to speak, compression which is a CRIME-attack vector anyway,
	# ENGINE support, etc.) that socat never touches, since a static build pulls in the entire
	# enabled algorithm set whether socat calls it or not. This is the single biggest lever on
	# final binary size. -Os and -ffunction-sections/-fdata-sections let the linker's
	# --gc-sections (set in build_socat) drop whatever unreferenced code remains.
	CC='/usr/bin/x86_64-alpine-linux-musl-gcc -static' \
		./Configure no-pic no-shared \
		no-idea no-mdc2 no-rc5 no-md2 no-whirlpool no-blake2 no-seed no-camellia no-cast \
		no-sm2 no-sm3 no-sm4 no-siphash no-ocb no-scrypt no-rmd160 no-argon2 no-aria no-siv \
		no-comp no-weak-ssl-ciphers no-ssl-trace no-engine no-psk no-srp no-egd \
		no-apps no-tests no-docs no-demos \
		-Os -ffunction-sections -fdata-sections \
		linux-x86_64

	# Build
	make -j20 || return 1
	echo "** Finished building OpenSSL"
}

function build_socat() {
	echo "=================================================== BUILDING SOCAT ==================================================="
	cd /build || return 1

	# Download
	curl -fLO http://www.dest-unreach.org/socat/download/socat-${SOCAT_VERSION}.tar.gz || return 1
	tar xzvf socat-${SOCAT_VERSION}.tar.gz || return 1
	cd socat-${SOCAT_VERSION} || return 1

	# Build
	# NOTE: `NETDB_INTERNAL` is non-POSIX, and thus not defined by MUSL.
	# We define it this way manually.
	CC='/usr/bin/x86_64-alpine-linux-musl-gcc -static' \
		CFLAGS="-fPIC -DWITH_OPENSSL -I/build -I/build/openssl-${OPENSSL_VERSION}/include -DNETDB_INTERNAL=-1 -Os -ffunction-sections -fdata-sections" \
		CPPFLAGS="-DWITH_OPENSSL -I/build -I/build/openssl-${OPENSSL_VERSION}/include -DNETDB_INTERNAL=-1" \
		LDFLAGS="-L/build/openssl-${OPENSSL_VERSION} -Wl,--gc-sections" \
		sc_cv_getprotobynumber_r=2 \
		./configure || return 1
	echo "=================================================== PATCHING SOCAT ==================================================="
	patch -p1 -i ../patches/socat_fix_static.patch || return 1
	patch -p1 -i ../patches/socat_fix_getprotobynumber.patch || return 1
	patch -p1 -i ../patches/socat_fix_abi_compliance_msghdr_xio-netlink.patch || return 1
	patch -p1 -i ../patches/socat_fix_openssl4.patch || return 1
	echo "=================================================== MAKING SOCAT ==================================================="
	make -j20 || return 1
	strip socat || return 1
}

function doit() {
	build_openssl || exit 1
	build_socat || exit 1

	# Copy to output
	if [ -d /output ]
	then
		OUT_DIR=/output
		mkdir -p $OUT_DIR
		cp /build/socat-${SOCAT_VERSION}/socat $OUT_DIR/ || return 1
		echo "** Finished building socat **"
	else
		echo "** /output does not exist **"
	fi
}

doit
