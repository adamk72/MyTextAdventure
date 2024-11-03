{-# LANGUAGE DeriveGeneric   #-}
{-# LANGUAGE DeriveAnyClass  #-}

module Core.State.GameState
    ( GameWorld(..)
    , GameEnvironment(..)
    , Metadata(..)
    ) where

import           Data.Text            (Text)
import           GHC.Generics         (Generic)
import           Data.Aeson           (FromJSON)
import           Core.State.Location  (Location)
import           Core.State.Entity    (Character, Interactable)

data GameWorld = GameWorld {
    activeCharacter    :: Character,
    playableCharacters :: [Character],
    locations          :: [Location],
    interactables     :: [Interactable]
} deriving (Show, Eq, Generic)

-- Note: FromJSON instance will be defined in JSON.hs

data Metadata = Metadata {
    title       :: Text,
    launchTag   :: Text,
    description :: Text,
    version     :: Text,
    author      :: Text
} deriving (Show, Eq, Generic, FromJSON)

data GameEnvironment = GameEnvironment {
    metadata :: Metadata,
    world    :: Maybe GameWorld
} deriving (Show, Eq, Generic)

-- Note: FromJSON instance will be defined in JSON.hs