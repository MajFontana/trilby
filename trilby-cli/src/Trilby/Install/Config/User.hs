module Trilby.Install.Config.User where

import Trilby.HNix
import Prelude

type Username = Text

data Password
    = PlainPassword !Text
    | HashedPassword !Text
    deriving stock (Generic)

data User = User
    { uid :: Int
    , username :: Username
    , password :: Maybe Password
    }
    deriving stock (Generic)

instance ToExpr User where
    toExpr User{..} =
        [nix|
        { trilby, lib, ... }:

        lib.trilbyUser trilby userAttrs
        |]
      where
        userAttrs =
            [nix|
            {
              uid = uid;
              name = username;
              initialPassword = initialPassword;
              initialHashedPassword = initialHashedPassword;
            }
            |]
                & canonicalSet
        (initialPassword, initialHashedPassword) =
            case password of
                Just (PlainPassword p) -> (Just p, Nothing)
                Just (HashedPassword p) -> (Nothing, Just p)
                Nothing -> (Nothing, Nothing)
