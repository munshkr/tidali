#!/bin/bash

C_LIBS=c-libs
HASKELL_LIBS=haskell-libs
GHCLIB=/home/munshkr/.stack/programs/x86_64-linux/ghc-8.6.5/lib/ghc-8.6.5/

mkdir -p $HASKELL_LIBS/package.conf.d

cp $GHCLIB/settings          $HASKELL_LIBS
cp $GHCLIB/platformConstants $HASKELL_LIBS
cp $GHCLIB/llvm-targets      $HASKELL_LIBS
cp $GHCLIB/llvm-passes       $HASKELL_LIBS

cp -r $GHCLIB/array-*            $HASKELL_LIBS
cp -r $GHCLIB/base-*             $HASKELL_LIBS
cp -r $GHCLIB/binary-*           $HASKELL_LIBS
cp -r $GHCLIB/bytestring-*       $HASKELL_LIBS
cp -r $GHCLIB/containers-*       $HASKELL_LIBS
cp -r $GHCLIB/deepseq-*          $HASKELL_LIBS
cp -r $GHCLIB/ghc-boot-*         $HASKELL_LIBS
cp -r $GHCLIB/ghc-prim-*         $HASKELL_LIBS
cp -r $GHCLIB/integer-gmp-*      $HASKELL_LIBS
cp -r $GHCLIB/mtl-*              $HASKELL_LIBS
#cp -r $GHCLIB/parsec-*           $HASKELL_LIBS
cp -r $GHCLIB/pretty-*           $HASKELL_LIBS
#cp -r $GHCLIB/rts                $HASKELL_LIBS
#cp -r $GHCLIB/stm-*              $HASKELL_LIBS
#cp -r $GHCLIB/template-haskell-* $HASKELL_LIBS
cp -r $GHCLIB/text-*             $HASKELL_LIBS
cp -r $GHCLIB/time-*             $HASKELL_LIBS
cp -r $GHCLIB/transformers-*     $HASKELL_LIBS
cp -r $GHCLIB/unix-*             $HASKELL_LIBS

cp -r $GHCLIB/package.conf.d/ $HASKELL_LIBS

cp -r $GHCLIB/include $HASKELL_LIBS

# Copy package configuration files from snapshot sandbox
package_sandbox=$(stack exec -- sh -c 'echo $HASKELL_PACKAGE_SANDBOX')
echo "Package sandbox: $package_sandbox"
cp -r $package_sandbox/*.conf $HASKELL_LIBS/package.conf.d/

# Copy packages from snapshot sandbox
cp -r /home/munshkr/.stack/snapshots/x86_64-linux/9f6a31a1b6bd2ddd2a3f10d4e6da4e0ef2aeccfda10b532a4f4acfb27236afab/8.6.5/lib/x86_64-linux-ghc-8.6.5/* $HASKELL_LIBS

# Update paths in package config files
perl -p -i -e 's!(/home/munshkr/projects/tidali-yaxu/.cabal-sandbox/lib/x86_64-linux-ghc-8.6.5|/home/munshkr/.stack/programs/x86_64-linux/ghc-8.6.5/lib/ghc-8.6.5/)!\$\{pkgroot\}/!g' \
    $HASKELL_LIBS/package.conf.d/*.conf

# TODO Delete data-dir, haddock-interfaces and haddock-html entries on .conf files

# Recache packages now because of updated paths 
stack exec -- ghc-pkg --package-db=$HASKELL_LIBS/package.conf.d recache
