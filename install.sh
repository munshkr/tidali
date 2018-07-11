#!/bin/bash

HASKELL_LIBS=/usr/local/tidali/haskell-libs
LINUX_LIBS=/usr/local/tidali/bin/linux-libs
TIDALI_BIN=/usr/local/tidali/bin

mkdir -p $TIDALI_BIN $HASKELL_LIBS $LINUX_LIBS

cp dist/build/tidali/tidali $TIDALI_BIN
cp fake_gcc.sh $TIDALI_BIN
chmod ugo+rx $TIDALI_BIN/fake_gcc.sh
cp -r haskell-libs/* $HASKELL_LIBS
cp -r linux-libs/* $LINUX_LIBS

