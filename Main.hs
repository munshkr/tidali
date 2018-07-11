module Main where

import           Control.Exception
import           Language.Haskell.Interpreter as Hint
import           Sound.Tidal.Context
import           System.IO
import           System.Posix.Signals
import           Control.Monad
import           Control.Concurrent.MVar

data Response = HintOK {parsed :: ParamPattern}
              | HintError {errorMessage :: String}

instance Show Response where
  show (HintOK p)    = "Ok: " ++ show p
  show (HintError s) = "Error: " ++ s

libs = ["Prelude","Sound.Tidal.Context","Sound.OSC.Datum"
       -- , "Sound.Tidal.Simple"
       ]

hintJob  :: (MVar String, MVar Response) -> IO ()
hintJob (mIn, mOut) =
  do installHandler sigINT Ignore Nothing
     installHandler sigTERM Ignore Nothing
     installHandler sigPIPE Ignore Nothing
     installHandler sigHUP Ignore Nothing
     installHandler sigKILL Ignore Nothing
     installHandler sigSTOP Ignore Nothing
     result <- catch (do Hint.runInterpreter $ do
                           _ <- liftIO $ installHandler sigINT Ignore Nothing
                           Hint.set [languageExtensions := [OverloadedStrings]]
                           --Hint.setImports libs
                           Hint.setImportsQ $ (Prelude.map (\x -> (x, Nothing)) libs) ++ [("Data.Map", Nothing)]
                           hintLoop
                     )
               (\e -> return (Left $ UnknownError $ "exception" ++ show (e :: SomeException)))
     let response = case result of
          Left err -> HintError (parseError err)
          Right p  -> HintOK p -- can happen
         parseError (UnknownError s) = "Unknown error: " ++ s
         parseError (WontCompile es) = "Compile error: " ++ (intercalate "\n" (Prelude.map errMsg es))
         parseError (NotAllowed s) = "NotAllowed error: " ++ s
         parseError (GhcException s) = "GHC Exception: " ++ s
         --parseError _ = "Strange error"

     takeMVar mIn
     putMVar mOut response
     hintJob (mIn, mOut)
     where hintLoop = do s <- liftIO (readMVar mIn)
                         t <- Hint.typeChecksWithDetails s
                         --interp check s
                         interp t s
                         hintLoop
           interp (Left errors) _ = do liftIO $ putMVar mOut $ HintError $ "Didn't typecheck" ++ (concatMap show errors)
                                       liftIO $ takeMVar mIn
                                       return ()
           interp (Right t) s | "Data.String.IsString" `isPrefixOf` t =
             do liftIO $ hPutStrLn stderr $ "type: " ++ t
                p <- Hint.interpret s (Hint.as :: Pattern String)
                liftIO $ putMVar mOut $ HintOK (sound p)
                liftIO $ takeMVar mIn
                return ()
                              | otherwise =
             do liftIO $ hPutStrLn stderr $ "type: " ++ t
                p <- Hint.interpret s (Hint.as :: ParamPattern)
                liftIO $ putMVar mOut $ HintOK p
                liftIO $ takeMVar mIn
                return ()

-- ultra-minimal for now, just takes a line and interprets it
main = do mIn <- newEmptyMVar
          mOut <- newEmptyMVar
          forkIO $ hintJob (mIn, mOut)
          forever $ do code <- getLine
                       putMVar mIn code
                       result <- takeMVar mOut
                       putStrLn $ show result
