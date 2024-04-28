SHELL = /bin/sh
OPTS = CRYSTAL_OPTS="--link-flags=-Wl,-ld_classic"
CC = ${OPTS} /usr/bin/time crystal build
BUILD_DIR = build
OUT_FILE = ${BUILD_DIR}/icon-replacer
SOURCE_FILES = src/icon-replacer.cr

build_and_test: clean test

clean:
	if [ ! -d "./${BUILD_DIR}" ]; then mkdir "${BUILD_DIR}"; else env echo "cleaning..." && rm -r ${BUILD_DIR}; mkdir "${BUILD_DIR}"; fi

build_test:
	${CC} ${SOURCE_FILES} -o ${OUT_FILE}_test --error-trace

test: build_test

${OUT_FILE}:
	${CC} ${SOURCE_FILES} -o ${OUT_FILE} --release --no-debug

release: clean ${OUT_FILE}
