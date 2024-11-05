{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# HLINT ignore "Fuse foldr/map" #-}

module Repl.Parse (parse) where

import           Command.Drop
import           Command.Get
import           Command.Go
import           Command.Look
import           Control.Applicative
import           Control.Monad.State
import           Core.Config         (quitCommands)
import           Core.State          (GameWorld)
import           Data.Text           (Text, isPrefixOf, strip, stripPrefix,
                                      toLower)

data Command = Command
  { cmdName    :: Text
  , cmdExecute :: Maybe Text -> State GameWorld Text
  }

commands :: [Command]
commands =
  [ Command "look" executeLook
  , Command "go" executeGo
  , Command "get" executeGet
  , Command "drop" executeDrop
  ]

tryCommand :: Text -> Text -> Command -> Maybe (State GameWorld Text)
tryCommand raw lower cmd = -- Todo: ask Claude about using Command{..} to replace this (which needs RecordWildCards)
  if cmdName cmd `isPrefixOf` lower
    then Just $ cmdExecute cmd (strip <$> stripPrefix (cmdName cmd) raw)
    else Nothing

parse :: Text -> State GameWorld (Maybe Text)
parse input = do
  let lower = toLower input
      -- Todo: Explain the foldr and <|> operator later in the blog; see below
      match = foldr (<|>) Nothing $ map (tryCommand input lower) commands
  case match of
    Just action -> do
        Just <$> action
        -- Todo: Note this as a trigger pattern
        -- result <- action
        -- return $ Just result
    Nothing     -> do
      if lower `elem` quitCommands
      then return Nothing
      else return $ Just $ "Don't know how to " <> lower <> "."

{-
(<|>) is the alternative operator from the Alternative typeclass in Haskell. For Maybe values, it acts like an "or" operation - it returns the first Just value it finds, or Nothing if both options are Nothing.
-}
