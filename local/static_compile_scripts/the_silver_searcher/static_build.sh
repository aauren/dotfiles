#!/bin/bash
GENTOO_REPO="/var/portage/repos/gentoo"
WORK_DIRECTORY="/var/tmp/portage/"
LIBPCRE_VERSION="8.39"
XZ_UTILS_VERSION="5.2.2"

LIBPCRE_WORK_DIR="${WORK_DIRECTORY}/dev-libs/libpcre-${LIBPCRE_VERSION}/work/pcre-${LIBPCRE_VERSION}"
XZ_UTILS_WORK_DIR="${WORK_DIRECTORY}/app-arch/xz-utils-${XZ_UTILS_VERSION}/work/xz-${XZ_UTILS_VERSION}"

build_deps() {
echo "+++++++++++++++++++++++++++++++++ Making libpcre +++++++++++++++++++++++++++++++++"
sleep 5
ebuild "${GENTOO_REPO}/dev-libs/libpcre/libpcre-${LIBPCRE_VERSION}.ebuild" unpack
pushd "${LIBPCRE_WORK_DIR}"
./configure
make
popd

echo "+++++++++++++++++++++++++++++++++ Making xz-utils +++++++++++++++++++++++++++++++++"
sleep 5
ebuild "${GENTOO_REPO}/app-arch/xz-utils/xz-utils-${XZ_UTILS_VERSION}.ebuild" unpack
pushd "${XZ_UTILS_WORK_DIR}"
./configure
make
popd
}

build_deps

echo "+++++++++++++++++++++++++++++++++ Making the_silver_searcher +++++++++++++++++++++++++++++++++"
sleep 5
PCRE_CFLAGS="-I ${LIBPCRE_WORK_DIR} -I ${XZ_UTILS_WORK_DIR}/src/liblzma/api" \
	PCRE_LIBS="-L ${LIBPCRE_WORK_DIR}/.libs -Wl,-Bstatic -lpcre -Wl,-Bdynamic" \
	LZMA_LIBS="-L ${XZ_UTILS_WORK_DIR}/src/liblzma/.libs -Wl,-Bstatic -llzma -Wl,-Bdynamic" \
	./build.sh
