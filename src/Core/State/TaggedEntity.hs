{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric  #-}

module Core.State.TaggedEntity (module Core.State.TaggedEntity) where

import           Core.State.Location
import           Data.Aeson          (FromJSON)
import           Data.Text           (Text)
import           GHC.Generics        (Generic)

data TaggedEntity = TaggedEntity
    { tag       :: Text
    , name      :: Text
    , location  :: Location
    , inventory :: Maybe Location
    } deriving (Show, Eq, Generic, FromJSON)

class Tagged a where
    getTag :: a -> Text
    getName :: a -> Text
    getLocation :: a -> Location
    getInventory :: a -> Maybe Location
