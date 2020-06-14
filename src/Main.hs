{-# language ScopedTypeVariables, LambdaCase #-}

module Main where

import qualified Language.Haskell.Interpreter as I
import qualified Sound.Tidal.Safe.Context as C
import Control.Monad (void)
import Control.Exception (throw)
import Control.Monad.IO.Class
import Control.Monad.Catch
-- import qualified Mueval.Resources as MR
import System.Timeout
import System.IO
import Data.Char (isSpace)
import Data.List (isPrefixOf)

main :: IO()
main = do
  -- from BootTidal.hs:
  tidal <- C.startTidal
    (C.superdirtTarget
      { C.oLatency = 0.1, C.oAddress = "127.0.0.1"
      , C.oPort = 57120})
    (C.defaultConfig {C.cFrameTimespan = 1/20})

  void $ I.runInterpreter
    $ catch (core tidal)
    $ \ (e :: SomeException) -> message stderr $ show e

core tidal = do
    message stdout "tidali starting..."
    -- more settings at
    -- https://github.com/tidalcycles/tidali/blob/master/src/Main.hs
    I.set [ I.languageExtensions
              I.:= [ I.OverloadedStrings ]
            , I.installedModulesInScope I.:= False
            ]
    I.setImports
      [ "Prelude"
      , "Sound.Tidal.Safe.Context"
      , "Sound.Tidal.Safe.Boot"
      ]
    -- FIXME: replace lazy IO by some streaming mechanism?
    message stdout "Modules loaded"
    input <- liftIO getContents
    mapM_ (work tidal . unlines) $ blocks $ lines input

second = 10^6 :: Int

-- Eval and print with a timeout of 1 second
message :: Handle -> String -> I.InterpreterT IO ()
message h s = do
  liftIO $ void $ timeout (1 * second) $ do
    hPutStrLn h s
    hFlush h

work :: C.Stream -> String -> I.InterpreterT IO ()
work tidal contents =
        ( if take 2 contents `elem` [ ":t", ":i", ":d" ]
          then do
            -- https://github.com/haskell-hint/hint/issues/101
            message stderr $ "error: '" <> contents <> "' not implemented"
          else
           I.typeChecksWithDetails contents >>= \case
             Left errs -> throw $ I.WontCompile errs
             Right s ->
               if s == "Op ()" then do -- execute, print nothing
                 -- TODO: need timeout for evaluation of pattern:
                 x <- I.interpret contents (I.as :: C.Op ())
                 -- have timeout for execution of pattern:
                 liftIO $ void $ timeout (1 * second) $ C.exec tidal x
               else do -- print type and value
                 if isPrefixOf "IO" s then do
                   message stderr "error: cannot show value, will not execute action"
                 else do
                   v <- I.eval contents
                   message stdout $ v <> " :: " <> s
        )
      `catch` \ (e :: I.InterpreterError) -> message stderr (unlines $ case e of
          I.UnknownError s -> [ "UnknownError", s ]
          I.WontCompile gs -> "WontCompile" : map I.errMsg gs
          I.NotAllowed s   -> [ "NotAllowed", s ]
          I.GhcException s -> [ "GhcException", s ]
        )
      `catch` \ (e :: SomeException) -> message stderr $ show e

blocks :: [String] -> [[String]]
blocks [] = []
blocks css =
  let blank = all isSpace
      (pre, midpost) = span blank css
      (mid, post) = span (not . blank) midpost
  in  mid : blocks post
