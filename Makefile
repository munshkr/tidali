
tidali: 
	ghc Main -o tidali
	cp /lib/x86_64-linux-gnu/libz.so.1 /lib/x86_64-linux-gnu/librt.so.1 /lib/x86_64-linux-gnu/libutil.so.1 /lib/x86_64-linux-gnu/libdl.so.2 /lib/x86_64-linux-gnu/libpthread.so.0 /usr/lib/x86_64-linux-gnu/libgmp.so.10 /lib/x86_64-linux-gnu/libm.so.6 /usr/lib/x86_64-linux-gnu/libffi.so.6 linux-libs/
