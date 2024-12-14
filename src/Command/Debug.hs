{-# LANGUAGE QuasiQuotes #-}
module Command.Debug (executeDebug) where

import           Command.CommandExecutor
import           Command.Message
import           Command.Message.Debug
-- import           Command.Replay
import           Core.GameMonad
import           Parser.Types
import           System.FilePath         ((</>))
import           Text.RawString.QQ

executeDebug :: CommandExecutor
executeDebug expr = do
    gw <- getWorld
    case expr of
        UnaryCmdExpression _ (NounClause "world") -> msg $ ShowWorldState $ formatWorld gw
        ComplexCmdExpression _ (NounClause "replay") _ (NounClause filename) -> undefine -- executeReplay $ "logs" </> filename
        _ -> msg $ InvalidDebugCommand [r|Valid debug commands are \":debug\" (or \":dbg\" or \":d\") followed by
    world                  -- gives current world information
    replay with <filename> -- replays file of log/<filename>|]
