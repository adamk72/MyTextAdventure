module Command.TestUtils (module Command.TestUtils) where

import           Command.CommandExecutor
import           Control.Monad.State
import           Core.State
import           Data.Text               (Text)
import           Parser.Types            (Expression)
import           Test.Hspec


-- | Run a command with an Expression
runCommand :: CommandExecutor -> Expression -> GameWorld -> (Text, GameWorld)
runCommand executor expr = runState (executor expr)

-- Common test context helpers
verifyStartLocation :: GameWorld -> Text -> Expectation
verifyStartLocation gw expectedLoc = do
    let acLoc = locTag $ getActiveActorLoc gw
    acLoc `shouldBe` expectedLoc
