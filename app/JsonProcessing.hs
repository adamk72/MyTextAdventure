{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}

module JsonProcessing (getJsonFilePaths, readAllMetadata, storyDirectory) where

import           Core.JSON.GameEnv    (GameEnvironmentJSON (..))
import           Core.JSON.Types      (Metadata (..))
import           Data.Aeson           (eitherDecode)
import qualified Data.ByteString.Lazy as B
import qualified Data.Either          as Either
import           System.Directory
import           System.FilePath      (takeExtension, (</>))

storyDirectory :: FilePath
storyDirectory = "stories"

getJsonFilePaths :: FilePath -> IO [Either String FilePath]
getJsonFilePaths dir = do
  allFiles <- listDirectory dir
  let jsonFiles = filter (\f -> takeExtension f == ".json") allFiles
  if null jsonFiles
    then return [Left "No adventure files found!"]
    else return (map (Right . (dir </>)) jsonFiles)

readMetadata :: FilePath -> IO (Either String Metadata)
readMetadata filePath = do
  content <- B.readFile filePath
  return $ fmap (fst . unGameEnvironment) (eitherDecode content :: Either String GameEnvironmentJSON)

readAllMetadata :: [Either String FilePath] -> IO [(FilePath, Either String Metadata)]
readAllMetadata filePaths = do
  let validPaths = Either.rights filePaths
  mapM processFile validPaths
  where
    processFile filePath = do
      md <- readMetadata filePath
      return (filePath, md)
