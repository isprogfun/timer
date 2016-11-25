module Routing exposing (..)

import String
import Navigation
import UrlParser exposing ((</>))
import Types exposing (..)
import Debug


-- Parser formatter a


matchers : UrlParser.Parser (Route -> a) a
matchers =
    -- List (Parser a b) -> Parser a b
    -- Simple, take a list of identical parsers and return one parser to rule them all
    UrlParser.oneOf
        -- map : a -> Parser a b -> Parser (b -> c) c
        -- So, Home and Timer returns after parse (Home will be just value of type Route)
        -- TimerPage will be function of type Route that takes String (the result of our parse)
        [ UrlParser.map TimerPage (UrlParser.s "timers" </> UrlParser.string)
          -- "#timers/timers/{id}"
        , UrlParser.map FormPage (UrlParser.s "new")
          -- "#new"
        ]


parseLocation : Navigation.Location -> Route
parseLocation location =
    case (UrlParser.parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundPage
