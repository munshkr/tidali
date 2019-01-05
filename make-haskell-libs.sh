#!/bin/bash

HASKELL_LIBS=haskell-libs
GHCLIB=/home/alex/.ghcup/ghc/8.6.3/lib/ghc-8.6.3

mkdir -p $HASKELL_LIBS/package.conf.d

cp $GHCLIB/settings $HASKELL_LIBS
cp $GHCLIB/platformConstants $HASKELL_LIBS
cp $GHCLIB/llvm-targets $HASKELL_LIBS
cp $GHCLIB/llvm-passes $HASKELL_LIBS

cp -r $GHCLIB/rts                               $HASKELL_LIBS
cp -r $GHCLIB/base-* $HASKELL_LIBS
cp -r $GHCLIB/ghc-prim*                         $HASKELL_LIBS
cp -r $GHCLIB/integ*                            $HASKELL_LIBS

cp -r $GHCLIB/package.conf.d/rts.conf           $HASKELL_LIBS/package.conf.d/
cp -r $GHCLIB/package.conf.d/base-*.conf        $HASKELL_LIBS/package.conf.d/
cp -r $GHCLIB/package.conf.d/ghc-prim-*.conf    $HASKELL_LIBS/package.conf.d/
cp -r $GHCLIB/package.conf.d/integer-gmp-*.conf $HASKELL_LIBS/package.conf.d/

cp -r $GHCLIB/include                            $HASKELL_LIBS

cabal sandbox init
cabal install --only-dependencies

cp -r .cabal-sandbox/lib/x86_64-linux-ghc-8.6.3/* $HASKELL_LIBS
cp -r .cabal-sandbox/*-packages.conf.d/*.conf $HASKELL_LIBS/package.conf.d/

perl -p -i -e 's!(/home/alex/src/tidali/.cabal-sandbox/lib/x86_64-linux-ghc-8.6.3|/home/alex/.ghcup/ghc/8.6.3/lib/ghc-8.6.3)!\$\{pkgroot\}!g' \
    $HASKELL_LIBS/package.conf.d/*.conf

ghc-pkg-8.6.3 --package-db=$HASKELL_LIBS/package.conf.d recache

