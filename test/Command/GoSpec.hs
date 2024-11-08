module Command.GoSpec (spec) where

import           Command.Common
import           Command.Go
import           Control.Exception    (ErrorCall (..), evaluate)
import           Control.Monad.State
import           Core.State
import           Data.List            (find)
import           Data.Text            (Text, unpack)
import           Mock.GameEnvironment
import           Test.Hspec

-- Helper function to execute state and get both result and final state
runCommand :: Text -> GameWorld -> (Text, GameWorld)
runCommand cmd = runState (executeGo cmd)

spec :: Spec
spec = describe "executeGo" $ do
    let startLocTag = "meadow"
        allowFromStartTag = "cave"
        noAllowFromStartTag = "forest"

    context "check testing assumptions" $ do
        it "should start the active character in the meadow" $ do
            let acLoc = locTag $ getActiveActorLoc defaultGW
            acLoc `shouldBe` startLocTag

        it "should have all location tags in list of gwLocations" $ do
            let locs = gwLocations defaultGW
            find (\x -> locTag x == startLocTag) locs `shouldBe` Just testMeadow
            find (\x -> locTag x == allowFromStartTag) locs `shouldBe` Just testCave
            find (\x -> locTag x == noAllowFromStartTag) locs `shouldBe` Just testForest

    context "when given a valid location" $ do
        it "prevents going to an unconnected location" $ do
            let (result, newState) = runCommand noAllowFromStartTag defaultGW
            result `shouldBe` renderMessage (NoPath noAllowFromStartTag)
            newState `shouldBe` defaultGW

        it "allows moving to a new, connected location" $ do
            let (result, newState) = runCommand allowFromStartTag defaultGW
            result `shouldBe` renderMessage (MovingToLocation allowFromStartTag)
            getLocation (gwActiveActor newState) `shouldBe` testCave

        it "prevents moving to current location" $ do
            let (result, newState) = runCommand startLocTag defaultGW
            result `shouldBe` renderMessage (AlreadyAtLocation startLocTag)
            newState `shouldBe` defaultGW

    context "when given an invalid location" $ do
        it "handles unknown gwLocations" $ do
            let (result, newState) = runCommand "nonexistent" defaultGW
            result `shouldBe` renderMessage (NoPath "nonexistent")
            newState `shouldBe` defaultGW

        it "errors out on bad starting location" $ do
            -- Actor tries moving to 'cave' which is not in the gwLocations list, but there is a locTag to
            -- from the character's current location; there's a JSON mismatch that breaks the game.
            let badSetupWorld = withLocations (withActorAt defaultGW testForest) [testMeadow]
                caveResult = evaluate (runCommand "cave" badSetupWorld)
            caveResult `shouldThrow` (\(ErrorCall msg) -> msg == unpack (renderMessage $ LocationDoesNotExist "cave"))

            -- alternate versions of badSetupWorld:
            -- let badSetupWorld = (flip withLocations [testMeadow] . flip withActorAt testForest) defaultGW
            -- let badSetupWorld = defaultGW & flip withActorAt testForest & flip withLocations [testMeadow]

