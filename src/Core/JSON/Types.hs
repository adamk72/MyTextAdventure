{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric  #-}

module Core.JSON.Types (EntityJSON (..), Location (..), Metadata (..), WorldJSON (..)) where

import           Core.JSON.ScenarioConverter (ScenarioJSON)
import           Data.Aeson
import           Data.Text                   (Text)
import           GHC.Generics                (Generic)

data EntityJSON = EntityJSON
  { jTag              :: Text,
    jTags             :: Maybe [Text],
    jName             :: Text,
    jLocTag           :: Maybe Text,
    jHasInventorySlot :: Maybe Bool
  }
  deriving (Show, Eq, Generic)

instance FromJSON EntityJSON where
  parseJSON = withObject "EntityJSON" $ \v -> do
    tag <- v .: "tag"
    types <- v .:? "types"
    name <- v .: "name"
    locTag <- v .: "locationTag"
    hasInv <- v .:? "hasInventorySlot"
    return
      EntityJSON
        { jTag = tag,
          jTags = types,
          jName = name,
          jLocTag = locTag,
          jHasInventorySlot = hasInv
        }

data Location = Location
  { locTag          :: Text,
    locTags         :: Maybe [Text],
    locName         :: Text,
    destinationTags :: [Text]
  }
  deriving (Show, Eq, Generic)

instance FromJSON Location where
  parseJSON = withObject "Location" $ \v -> do
    tag <- v .: "tag"
    types <- v .:? "types"
    name <- v .: "name"
    dests <- v .: "destinationTags"
    return
      Location
        { locTag = tag,
          locTags = types,
          locName = name,
          destinationTags = dests
        }

data WorldJSON = WorldJSON
  { jStartingActorTag :: Text,
    jPlayableActors   :: [EntityJSON],
    jLocations        :: [Location],
    jItems            :: [EntityJSON],
    jScenarios        :: Maybe [ScenarioJSON]
  }
  deriving (Show, Eq, Generic)

instance FromJSON WorldJSON where
  parseJSON = withObject "WorldJSON" $ \v -> do
    startActor <- v .: "startingActor"
    actors <- v .: "characters"
    locs <- v .: "locations"
    items <- v .: "items"
    scenarios <- v .:? "scenarios"
    return
      WorldJSON
        { jStartingActorTag = startActor,
          jPlayableActors = actors,
          jLocations = locs,
          jItems = items,
          jScenarios = scenarios
        }

data Metadata = Metadata
  { title       :: Text,
    launchTag   :: Text,
    description :: Text,
    version     :: Text,
    author      :: Text
  }
  deriving (Show, Eq, Generic, FromJSON)
