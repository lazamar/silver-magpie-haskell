{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}

module Types where

import Control.Monad.Database
    ( Collection (..),
      Database (..),
      FromRecord,
      MonadDB,
      Target (..),
      ToRecord,
      ToValue,
    )
import Control.Monad.Database.SQLite (MonadSQL, MonadSQLT)
import Control.Monad.Error.Class (MonadError)
import Control.Monad.Except (ExceptT (..))
import Control.Monad.IO.Class (MonadIO)
import Data.Aeson.Types (FromJSON, ToJSON)
import Data.AppAuth (AppAuth)
import Data.Text (Text)
import Data.UserDetails (UserDetails)
import GHC.Generics (Generic)
import Servant.Server (ServerError)

data Environment
    = Development
    | Production
    deriving (Show , Generic)

instance FromJSON Environment

data EnvironmentVariables = EnvironmentVariables
    { environment :: Environment
    , port :: Int
    , domain :: Text
    , dbName :: Text
    , dbUrl :: Text
    , dbPort :: Int
    , dbUsername :: Text
    , dbPassword :: Text
    , twitterKey :: Text
    , twitterSecret :: Text
    }
    deriving (Show , Generic)

instance FromJSON EnvironmentVariables

-- API Types

newtype InfoMsg = InfoMsg {status :: String}
    deriving (Generic , Show)

instance ToJSON InfoMsg

type HandlerM m =
    ( MonadDB m
    , MonadIO m
    , MonadError ServerError m
    , ToValue m String
    , ToValue m Text
    , FromRecord m AppAuth
    , FromRecord m UserDetails
    , ToRecord m UserDetails
    , ToRecord m AppAuth
    )

type Stack = MonadSQLT (ExceptT ServerError IO)

targetCollection :: Text -> Target
targetCollection = Target (Database "Noop") . Collection
