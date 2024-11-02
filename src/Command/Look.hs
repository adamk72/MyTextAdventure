{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# LANGUAGE LambdaCase #-}
{-# HLINT ignore "Use newtype instead of data" #-}

module Command.Look (executeLook, LookMessage(..), renderMessage) where

import           Control.Monad.State
import           Core.State
import           Data.Text           as T

data LookMessage
    = LookAround
    | YouAreIn Text
    | LookTowards Text

renderMessage :: LookMessage -> Text
renderMessage = \case
    LookAround -> "You look around carefully, taking in your surroundings."
    YouAreIn loc ->  "You are in " <> loc <> "."
    LookTowards dir -> "You look " <> dir <> ", but see nothing special."

executeLook :: Maybe Text -> State GameWorld Text
executeLook (Just "around") = do
    gw <- get
    let loc = locName $ getActiveCharLocFromGW activeCharacter gw
    return $ renderMessage (YouAreIn loc) <> " " <> renderMessage LookAround
executeLook Nothing = do
    gw <- get
    let loc = locName $ getActiveCharLocFromGW activeCharacter gw
    return $ renderMessage $ YouAreIn loc
executeLook (Just direction) = do
    return (renderMessage $ LookTowards direction)
