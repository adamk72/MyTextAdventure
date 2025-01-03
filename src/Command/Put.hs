module Command.Put (executePut) where

import           Command.Executor
import           Command.Message
import           Core.GameMonad
import           Core.State
import           Entity.Class.Capacity   (HasCapacity, changeItemContainer)
import           Entity.Class.EntityBase (HasEntityBase)
import           Entity.Entity
import           Entity.Types.Common
import           Parser.Types
import           Parser.Utils            (isPrepVariantOf)
import           Utils                   (ItemTag, LocationTag)

putItemInContainer :: ItemTag -> LocationTag -> World -> GameStateText
putItemInContainer itemTag containerTag gw =
  case findEntityById itemId gw of
    Just (ItemResult item)
      | item `elem` itemsInLoc || item `elem` itemsOnActor ->
          tryToAddItemToContainer item
    _ -> msg $ DontSeeItem itemTag
  where
    itemId = EntityId itemTag
    containerId = EntityId containerTag
    itemsInLoc = getEntityInventoryList (getActiveActorLocation gw) gw
    itemsOnActor = getActiveActorInventoryList gw

    tryToAddItemToContainer :: Entity 'ItemT -> GameStateText
    tryToAddItemToContainer item =
      case findEntityById containerId gw of
        Just (ItemResult container)    -> addItemToContainer container item
        Just (ActorResult actor)       -> addItemToContainer actor item
        Just (LocationResult location) -> addItemToContainer location item
        _                              -> msg $ DontSeeItem itemTag

    -- Todo: fix the problem where the tardis can be in the bag and the bag in the tardis.
    addItemToContainer :: (HasCapacity a, HasEntityBase a) => Entity a -> Entity 'ItemT -> GameStateText
    addItemToContainer container item =
      case changeItemContainer container item gw of
        Right updatedGW -> do
          modifyWorld (const updatedGW)
          return $ "You put " <> itemTag <> " in " <> containerTag <> "."
        Left errMsg -> return errMsg

executePut :: BasicCommandExecutor
executePut expr = do
  gw <- getWorld
  case expr of
    AtomicCmdExpression {} ->
      msg PutWhat
    UnaryCmdExpression _ (NounClause itemTag) ->
      msg $ PutWhere itemTag
    SplitCmdExpression {} ->
      msg PutWhat
    ComplexCmdExpression _ (NounClause itemTag) (PrepClause prep) (NounClause containerTag)
      | prep `isPrepVariantOf` "in" ->
          putItemInContainer itemTag containerTag gw
    ComplexCmdExpression {} -> return "TBD"
