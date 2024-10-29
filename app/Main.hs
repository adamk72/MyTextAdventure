{-# LANGUAGE LambdaCase #-}

import           CmdOptions         as Cmd (parse, showHelp)
import           Control.Monad      (void)
import qualified Core.Launch        as Core
import           Data.List          (find)

import           Data.Text          as T (Text, concat, intercalate, pack,
                                          unpack)
import qualified Data.Text.IO       as TIO
import           Json               (JMetadata (..))
import           JsonProcessing     as Help (getJsonFilePaths, readAllMetadata,
                                             storyDirectory)
import           System.Environment as E (getArgs)

newtype AdventureName = AdventureName { unAdventureName :: Text }
data AdventureInfo = AdventureInfo
    { filePath       :: FilePath
    , advTitle       :: Text
    , advLaunchTag   :: Text
    , advDescription :: Text
    } deriving (Show)

-- Convert metadata to our domain type
toAdventureInfo :: (FilePath, JMetadata) -> AdventureInfo
toAdventureInfo (fp, meta) = AdventureInfo
    { filePath = fp
    , advTitle = title meta
    , advLaunchTag = launchTag meta
    , advDescription = description meta
    }

formatAdventureInfo :: AdventureInfo -> Text
formatAdventureInfo adv = T.concat
    [ advTitle adv
    , " ("
    , advLaunchTag adv
    , ") -"
    , advDescription adv
    ]

data Command
    = RunAdventure AdventureName
    | ShowHelp
    | InvalidAdventure Text

parseArgs :: [AdventureName] -> [String] -> Command
parseArgs validNames = \case
    ["-a", option] ->
        let name = pack option
        in if name `elem` map unAdventureName validNames
           then RunAdventure (AdventureName name)
           else InvalidAdventure name
    _ -> ShowHelp

main :: IO ()
main = do
    jsonPaths <- getJsonFilePaths storyDirectory
    metadataResults <- readAllMetadata jsonPaths

    let adventures = map toAdventureInfo metadataResults
        validNames = map (AdventureName . advLaunchTag) adventures
        formattedAdventures = map formatAdventureInfo adventures

    E.getArgs >>= \args ->
        case parseArgs validNames args of
            RunAdventure name -> do
                case find (\adv -> advLaunchTag adv == unAdventureName name) adventures of
                    Just adv -> runGameWithOption (filePath adv)
                    Nothing  -> TIO.putStrLn "Error: Adventure not found"
            InvalidAdventure name -> do
                TIO.putStrLn $ "Invalid adventure name: " <> name <> "\n"
                Cmd.showHelp (unpack $ intercalate "\n" formattedAdventures)
            ShowHelp ->
                displayHelp formattedAdventures

displayHelp :: [Text]-> IO ()
displayHelp = void . Cmd.parse . unpack . intercalate "\n"

runGameWithOption :: FilePath -> IO ()
runGameWithOption option = do
    putStrLn $ "Running game with option: " ++ option
    runGame option

runGame :: FilePath -> IO ()
runGame = Core.launch


{- For later comparison on how `case` is very flexible:
RunAdventure name -> do
    let matchingAdventure = filter (\adv -> advLaunchTag adv == unAdventureName name) adventures
    case matchingAdventure of
        [adv] -> do -- [adv] is used for pattern matching a list with one element only
            runGameWithOption (pack $ filePath adv)  -- Pass the file path instead of the launch tag
        _ -> TIO.putStrLn "Error: Adventure not found or multiple matches found"
-}
