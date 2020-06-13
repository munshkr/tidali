module Main where

import Language.Haskell.Interpreter as Hint
import Language.Haskell.Interpreter.Unsafe as Hint
import Sound.Tidal.Context
import Control.Monad
import Control.Concurrent.MVar
import Data.List (intercalate)

libdir = "haskell-libs"

libs = ["Prelude", "Sound.Tidal.Context"]

main :: IO ()
main = do r <- Hint.unsafeRunInterpreterWithArgsLibdir [] libdir f
          case r of
            Left err -> putStrLn $ errorString err
            Right () -> return ()

errorString :: InterpreterError -> String
errorString (WontCompile es) = intercalate "\n" (header : map unbox es)
  where
    header = "ERROR: Won't compile:"
    unbox (GhcError e) = e
errorString e = show e

say :: String -> Interpreter ()
say = liftIO . putStrLn

emptyLine :: Interpreter ()
emptyLine = say ""

f :: Interpreter ()
f =  do say "set language extensions"
        Hint.set [languageExtensions := [OverloadedStrings]]
        say "set imports"
        Hint.setImportsQ $ (Prelude.map (\x -> (x, Nothing)) libs)
        emptyLine
        say "interpret 1 + 2"
        p <- Hint.interpret "1 + 2" (Hint.as :: Int)
        say $ show p
        emptyLine
