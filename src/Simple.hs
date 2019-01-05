module Simple where

-- import           Control.Exception
import           Language.Haskell.Interpreter as Hint
import           Language.Haskell.Interpreter.Unsafe as Hint
import           Sound.Tidal.Context
-- import           System.IO
-- import           System.Posix.Signals
import           Control.Monad
import           Control.Concurrent.MVar
import           Data.List (isPrefixOf,intercalate)

libdir = "/home/alex/src/tidali/haskell-libs"

libs = ["Prelude","Sound.Tidal.Context" -- ,"Sound.OSC.Datum"
       -- , "Sound.Tidal.Simple"
       ]

main = do Hint.unsafeRunInterpreterWithArgsLibdir [] libdir f

f :: Interpreter ()
f =  do Hint.set [languageExtensions := [OverloadedStrings]]
        Hint.setImportsQ $ (Prelude.map (\x -> (x, Nothing)) libs)
        -- t <- Hint.typeChecksWithDetails s
        p <- Hint.interpret "1 + 2" (Hint.as :: Int)
        liftIO $ putStrLn $ show p
        return ()
