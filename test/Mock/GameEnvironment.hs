module Mock.GameEnvironment  (module Mock.GameEnvironment) where

import           Core.State
import           Test.Hspec ()

-- Common test gwLocations
testCave :: Location
testCave = Location
    { locTag = "cave"
    , locName = "A dark cave"
    , destinationTags = ["meadow", "forest"]
    }

testMeadow :: Location
testMeadow = Location
    { locTag = "meadow"
    , locName = "A flowery meadow"
    , destinationTags = ["cave"]
    }

testForest :: Location
testForest = Location
    { locTag = "forest"
    , locName = "A dense forest"
    , destinationTags = ["cave"]
    }

-- Common test characters
testAlice :: Location -> Actor
testAlice loc = mkActor TaggedEntity
    { tag = "alice"
    , name = "Alice the Adventurer"
    , location = loc
    , inventory = Just [Location { locTag = "alice", locName = "your pockets", destinationTags = [] }]
    }

testBob :: Location -> Actor
testBob loc = mkActor TaggedEntity
    { tag = "bob"
    , name = "Bob the Brave"
    , location = loc
    , inventory = Just [Location { locTag = "bob", locName = "your pockets", destinationTags = [] }]
    }

testItems :: [Item]
testItems =
    [
    mkItem TaggedEntity
        { tag = "silver coin"
        , name = "a sliver coin"
        , location = testMeadow
        , inventory = Nothing
        },
    mkItem TaggedEntity
        { tag = "eight ball"
        , name = "a magic eight ball"
        , location = testForest
        , inventory = Nothing
        }
    ]

-- World builders
makeTestWorld :: Actor -> [Actor] -> [Location] -> [Item] -> GameWorld
makeTestWorld active playable locs inters = GameWorld
    { getActiveActor = active
    , gwPlayableActors = playable
    , gwLocations = locs
    , gwItems = inters
    }

-- Common world configurations
defaultGW :: GameWorld
defaultGW = makeTestWorld
    (testAlice testMeadow)
    [testBob testMeadow]
    [testCave, testMeadow, testForest]
    testItems

-- Helper functions for common test operations
withActorAt :: GameWorld -> Location -> GameWorld
withActorAt w newLoc = w
    { getActiveActor = setActorLoc newLoc (getActiveActor w) }

withLocations :: GameWorld -> [Location] -> GameWorld
withLocations w locs = w { gwLocations = locs }

-- withPlayableActors :: GameWorld -> [Actor] -> GameWorld
-- withPlayableActors world actors = world { gwPlayableActors = actors }
