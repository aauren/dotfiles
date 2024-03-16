#!/bin/bash

function build_bfs() {
	cd /build

	# Download
	cd bfs_build

	# Build
	make LDFLAGS="-static"
	strip bin/bfs
}

function doit() {
	build_bfs || exit 1

	# Copy to output
	if [ -d /output ]
	then
		OUT_DIR=/output
		mkdir -p $OUT_DIR
		cp /build/bfs_build/bin/bfs $OUT_DIR/
		echo "** Finished building bfs **"
	else
		echo "** /output does not exist **"
	fi
}

doit
