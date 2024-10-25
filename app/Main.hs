{-# LANGUAGE LambdaCase        #-}

import           CmdOptions         as Cmd (parse, showHelp)
import           Control.Monad      (void)
import qualified Core.Launch        as Core
import           Data.Text          as T (Text, concat, intercalate, pack,
                                          unpack)
import           JsonProcessing     as Help (AdventureDetail (description, fullName, shortName),
                                             getJsonFilePaths, processJsonFiles,
                                             storyDirectory)
import           System.Environment as E (getArgs)

validOptions :: [String]
validOptions = ["Trial", "Foo", "Bar"]

main :: IO ()
main = do
    jsonPaths <- getJsonFilePaths storyDirectory
    content <- processJsonFiles jsonPaths
    E.getArgs >>= \case
        ["-a", option] | option `elem` validOptions -> runGameWithOption option
        ["-a", invalid] -> do
            putStrLn $ "Invalid adventure name: " ++ invalid ++ "\n"
            let adventureList = T.unpack $ T.intercalate "\n" (concatResults content)
            Cmd.showHelp adventureList
        _ -> displayHelp (concatResults content)
        where
            concatResults :: [Either String AdventureDetail] -> [Text]
            concatResults = map formatResult
                where
                    formatResult (Right adv) =
                        T.concat [fullName adv, " (", shortName adv, ") -", description adv]
                    formatResult (Left err)= T.concat [T.pack err]

displayHelp :: [Text]-> IO ()
displayHelp = void . Cmd.parse . T.unpack . T.intercalate "\n"

runGameWithOption :: String -> IO ()
runGameWithOption option = do
    putStrLn $ "Running game with option: " ++ option
    runGame

runGame :: IO ()
runGame = Core.launch
