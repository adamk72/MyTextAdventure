{-# LANGUAGE LambdaCase #-}
module Command.Go (module Command.Go) where

import           Command.Common
import           Control.Monad.State
import           Core.State
import           Data.List           (find)
import           Data.Text           (Text, unpack)

data GoMessage
    = AlreadyAtLocation Text
    | MovingToLocation Text
    | DoesNotExist Text
    | NoLocationSpecified
    | NoPath Text
    deriving (Eq, Show)

instance CommandMessage GoMessage where
    renderMessage = \case
        AlreadyAtLocation loc -> "You're already in " <> loc <> "."
        MovingToLocation loc -> "Moving to " <> loc <> "."
        DoesNotExist loc -> "Location does not exist in this game world: " <> loc <> "."
        NoPath loc -> "There is no indication there's a way to get to \"" <> loc <> "\"."
        NoLocationSpecified -> "Unable to find a location at all."

executeGo :: CommandExecutor
executeGo target = do
    gw <- get
    let ac = gwActiveActor gw
        validLocTags = destinationTags $ getLocation ac
    case target of
        moveTo | moveTo `elem` validLocTags ->
            case find (\loc -> locTag loc == moveTo) (gwLocations gw) of
                Just newLoc -> do
                    let newAc = setActorLoc newLoc ac
                    put gw { gwActiveActor = newAc }
                    return $ renderMessage $ MovingToLocation moveTo
                Nothing -> error $ unpack $ renderMessage $ DoesNotExist moveTo
        already | already == locTag (getLocation ac) ->
            return $ renderMessage $ AlreadyAtLocation already
        noWay -> return $ renderMessage $ NoPath noWay
