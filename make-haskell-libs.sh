#!/bin/bash

HASKELL_LIBS=haskell-libs
LINUX_LIBS=linux-libs

mkdir -p $HASKELL_LIBS $LINUX_LIBS

mkdir -p $HASKELL_LIBS/package.conf.d

cp /usr/lib/ghc/settings $HASKELL_LIBS
sed -i 's/\/usr\/bin\/gcc/\/usr\/local\/tidali\/bin\/fake_gcc.sh/g' $HASKELL_LIBS/settings
cp /usr/lib/ghc/platformConstants $HASKELL_LIBS

cp -r /usr/lib/ghc/base* $HASKELL_LIBS
cp -r /usr/lib/ghc/package.conf.d/base-*.conf $HASKELL_LIBS/package.conf.d/ && \
    

cp /usr/lib/x86_64-linux-gnu/libgmp.so.10 $LINUX_LIBS
ln -s libgmp.so.10                        $LINUX_LIBS/libgmp.so


cp -r /usr/lib/ghc/rts                               $HASKELL_LIBS
cp -r /usr/lib/ghc/ghc-prim*                         $HASKELL_LIBS
cp -r /usr/lib/ghc/integ*                            $HASKELL_LIBS

cp -r /usr/lib/ghc/package.conf.d/rts.conf           $HASKELL_LIBS/package.conf.d/
cp -r /usr/lib/ghc/package.conf.d/base-*.conf        $HASKELL_LIBS/package.conf.d/
cp -r /usr/lib/ghc/package.conf.d/ghc-prim-*.conf    $HASKELL_LIBS/package.conf.d/
cp -r /usr/lib/ghc/package.conf.d/integer-gmp-*.conf $HASKELL_LIBS/package.conf.d/

sed -i 's/\/usr\/lib\/ghc/\/usr\/local\/tidali\/haskell-libs/g' \
    $HASKELL_LIBS/package.conf.d/rts.conf
sed -i 's/\/usr\/lib\/ghc/\/usr\/local\/tidali\/haskell-libs/g' \
    $HASKELL_LIBS/package.conf.d/base-*.conf
sed -i 's/\/usr\/lib\/ghc/\/usr\/local\/tidali\/haskell-libs/g' \
    $HASKELL_LIBS/package.conf.d/ghc-prim-*.conf
sed -i 's/\/usr\/lib\/ghc/\/usr\/local\/tidali\/haskell-libs/g' \
    $HASKELL_LIBS/package.conf.d/integer-gmp-*.conf

cp -r .cabal-sandbox/lib/x86_64-linux-ghc-8.0.2/* $HASKELL_LIBS

rm -rf tmp
mkdir tmp
cp -r .cabal-sandbox/*-packages.conf.d/*.conf tmp
sed -i 's/\/home\/alex\/src\/tidali\/.cabal-sandbox\/lib\/x86_64-linux-ghc-8.0.2/\/usr\/local\/tidali\/haskell-libs/g' \
    tmp/*conf
cp -r tmp/*.conf $HASKELL_LIBS/package.conf.d/

ghc-pkg --package-db=$HASKELL_LIBS/package.conf.d recache
