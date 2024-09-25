{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TypeOperators #-}

module Main where

import GHC.Generics (Generic)
import Network.Wai.Handler.Warp (run)
import Servant
import Servant.Server.Generic
import System.Environment

main :: IO ()
main = do
  [port] <- getArgs
  run (read port) $ genericServe server

data API route = API
  {endpoint :: route :- Get '[JSON] Int}
  deriving (Generic)

server :: API AsServer
server =
  API
    { endpoint = pure 1783
    }
