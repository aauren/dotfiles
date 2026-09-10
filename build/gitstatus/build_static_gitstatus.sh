#!/bin/bash

# Builds a statically linked gitstatusd for whatever architecture this container is running as. We rely on the
# upstream build script for the actual compile (it already handles static-pie linking on musl), we just make sure that
# the result really is static and name it by kernel and arch, the same way upstream names its release binaries.
# see: https://github.com/romkatv/gitstatus#compiling

function build_gitstatus() {
	echo "=================================================== BUILDING gitstatusd ==================================================="
	cd /build/gitstatus_build || return 1

	# -w downloads the libgit2 tarball into ./deps, tools are already installed via the Dockerfile so no -s here. We
	# need _LARGEFILE64_SOURCE because musl >= 1.2.5 no longer exposes ino64_t / off64_t under _GNU_SOURCE alone,
	# which upstream sidesteps by pinning a very old alpine image
	CXXFLAGS="-D_LARGEFILE64_SOURCE" ./build -w || return 1

	# The build script already runs a smoke test against a scratch repo, but we also want to be sure that nothing dynamic
	# snuck in, since the whole point of this is to not depend on anything on the target system
	if ldd usrbin/gitstatusd 2>/dev/null | grep -q "=>"; then
		echo "** gitstatusd is not statically linked **"
		ldd usrbin/gitstatusd
		return 1
	fi
	file usrbin/gitstatusd
}

function doit() {
	build_gitstatus || exit 1

	# Copy to output
	if [[ -d /output ]]; then
		OUT_DIR=/output
		mkdir -p $OUT_DIR
		cp /build/gitstatus_build/usrbin/gitstatusd "${OUT_DIR}/gitstatusd-linux-$(uname -m)"
		echo "** Finished building gitstatusd-linux-$(uname -m) **"
	else
		echo "** /output does not exist **"
	fi
}

doit
