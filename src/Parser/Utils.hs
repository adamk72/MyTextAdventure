module Parser.Utils (getPrepVariants, isPrepVariantOf, knownArticles, knownPreps, verbsRequiringObjects) where
import           Data.Text (Text, words)

import           Prelude   hiding (words)

verbsRequiringObjects :: [Text]
verbsRequiringObjects = ["put", "place", "move", "set"]

knownPreps :: [(Text, [[Text]])]
knownPreps =
    [ ("in", [["in"], ["inside"], ["into"], ["in", "to"]])
    , ("on", [["on"], ["onto"], ["upon"], ["on", "top", "of"]])
    , ("under", [["under"], ["beneath"], ["underneath"]])
    , ("at", [["at"], ["towards"], ["toward"]])
    , ("from", [["from"], ["out", "of"]])
    , ("to", [["to"]])
    , ("toward", [["toward"], ["towards"]])
    ]

knownArticles :: [Text]
knownArticles = ["the", "a", "an"]

getPrepVariants :: Text -> Maybe [[Text]]
getPrepVariants basePrep = lookup basePrep knownPreps

isPrepVariantOf :: Text -> Text -> Bool
isPrepVariantOf basePrep variantPhrase = case getPrepVariants basePrep of
    Nothing -> False  -- Base preposition doesn't exist
    Just variants -> let words' = words variantPhrase
                    in words' `elem` variants
