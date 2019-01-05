#!/bin/bash

HASKELL_LIBS=haskell-libs
GHCLIB=/home/alex/.ghcup/ghc/8.6.3/lib/ghc-8.6.3

mkdir -p $HASKELL_LIBS/package.conf.d

cp $GHCLIB/settings $HASKELL_LIBS
cp $GHCLIB/platformConstants $HASKELL_LIBS
cp $GHCLIB/llvm-targets $HASKELL_LIBS
cp $GHCLIB/llvm-passes $HASKELL_LIBS

cp -r $GHCLIB/rts                               $HASKELL_LIBS
cp -r $GHCLIB/base-*                            $HASKELL_LIBS
cp -r $GHCLIB/ghc-prim*                         $HASKELL_LIBS
cp -r $GHCLIB/integ*                            $HASKELL_LIBS
cp -r $GHCLIB/containers*                       $HASKELL_LIBS
cp -r $GHCLIB/array*                            $HASKELL_LIBS
cp -r $GHCLIB/deepseq*                          $HASKELL_LIBS
cp -r $GHCLIB/transformers*                     $HASKELL_LIBS
cp -r $GHCLIB/template-haskell*                 $HASKELL_LIBS
cp -r $GHCLIB/text*                             $HASKELL_LIBS
cp -r $GHCLIB/binary*                           $HASKELL_LIBS
cp -r $GHCLIB/bytestring*                       $HASKELL_LIBS
cp -r $GHCLIB/time*                             $HASKELL_LIBS
cp -r $GHCLIB/mtl*                              $HASKELL_LIBS
cp -r $GHCLIB/ghc-boot*                         $HASKELL_LIBS
cp -r $GHCLIB/pretty*                           $HASKELL_LIBS
cp -r $GHCLIB/parsec*                           $HASKELL_LIBS
cp -r $GHCLIB/stm*                              $HASKELL_LIBS
cp -r $GHCLIB/unix*                             $HASKELL_LIBS

cp -r $GHCLIB/package.conf.d/*.conf             $HASKELL_LIBS/package.conf.d/

cp -r $GHCLIB/include                           $HASKELL_LIBS

cabal sandbox init
cabal install --only-dependencies

cp -r .cabal-sandbox/lib/x86_64-linux-ghc-8.6.3/* $HASKELL_LIBS
cp -r .cabal-sandbox/*-packages.conf.d/*.conf $HASKELL_LIBS/package.conf.d/

# perl -p -i -e 's!(/home/alex/src/tidali/.cabal-sandbox/lib/x86_64-linux-ghc-8.6.3|/home/alex/.ghcup/ghc/8.6.3/lib/ghc-8.6.3)!\$\{pkgroot\}!g' \
perl -p -i -e 's!(/home/alex/src/tidali/.cabal-sandbox/lib/x86_64-linux-ghc-8.6.3|/home/alex/.ghcup/ghc/8.6.3/lib/ghc-8.6.3)!\$\{pkgroot\}!g' \
    $HASKELL_LIBS/package.conf.d/*.conf

ghc-pkg-8.6.3 --package-db=$HASKELL_LIBS/package.conf.d recache

