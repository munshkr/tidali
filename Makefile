.PHONY: build c-libs haskell-libs clean

HSLIBS_DIR := haskell-libs
CLIBS_DIR := c-libs
LIBS := /lib/x86_64-linux-gnu/libtinfo.so.5 \
	/lib/x86_64-linux-gnu/libz.so.1 \
	/lib/x86_64-linux-gnu/librt.so.1 \
	/lib/x86_64-linux-gnu/libutil.so.1 \
	/lib/x86_64-linux-gnu/libdl.so.2 \
	/lib/x86_64-linux-gnu/libpthread.so.0 \
	/usr/lib/x86_64-linux-gnu/libgmp.so.10 \
	/lib/x86_64-linux-gnu/libm.so.6 \
	/usr/lib/x86_64-linux-gnu/libffi.so.6

all: build c-libs hs-libs

build:
	stack install --local-bin-path .

c-libs:
	mkdir -p c-libs/
	cp $(LIBS) c-libs/

hs-libs:
	./make-haskell-libs.sh

clean:
	stack clean
	rm -rf $(HSLIBS_DIR) $(CLIBS_DIR)
