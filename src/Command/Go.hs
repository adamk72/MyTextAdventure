module Command.Go (executeGo) where

import           Command.Executor
import           Command.Message
import           Core.GameMonad
import           Core.GameState
import           Data.Maybe               (fromMaybe)
import           Data.Text                (Text)
import           Entity.Class.CanMoveSelf
import           Entity.Ops.Location      (getLocationDestinations)
import           Entity.Types.Common
import           Parser.Types
import           Scenario.Check

moveTo :: Text -> World -> GameStateText
moveTo dstTag gw
  | currLocTag == dstTag = msg $ AlreadyAtLocation dstTag
  | dstId `elem` dstIds = do
      let newAc = setLocationId dstId ac
      modifyWorld $ \w -> w {activeActor = newAc}
      msg $ MovingToLocation dstTag
  | otherwise = msg $ NoPath dstTag
  where
    ac = activeActor gw
    dstId = EntityId dstTag
    currLocTag = unEntityId $ getLocationId ac
    dstIds = fromMaybe [] (getLocationDestinations (getLocationId ac) gw)

executeGo :: ScenarioCheckExecutor
executeGo = toScenarioCheck executeGoRaw

executeGoRaw :: World -> BasicCommandExecutor
executeGoRaw gw expr = do
  case expr of
    (AtomicCmdExpression _)                   -> msg GoWhere
    (UnaryCmdExpression _ (NounClause dst))   -> moveTo dst gw
    (SplitCmdExpression _ _ (NounClause dst)) -> moveTo dst gw
    _                                         -> msg NotSure
