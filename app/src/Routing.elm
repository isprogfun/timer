module Routing exposing (..)

import String
import Navigation
import UrlParser exposing ((</>))
import Types exposing (..)
import Debug


-- What is Result String Route
-- http://guide.elm-lang.org/error_handling/result.html


routeFromResult : Result String Route -> Route
routeFromResult result =
    case result of
        Ok route ->
            route

        Err message ->
            NotFoundPage
                message



-- Parser formatter a


matchers : UrlParser.Parser (Route -> a) a
matchers =
    -- List (Parser a b) -> Parser a b
    -- Simple, take a list of identical parsers and return one parser to rule them all
    UrlParser.oneOf
        -- format : formatter -> Parser formatter a -> Parser (a -> result) result
        -- So, Home and Timer returns after parse (Home will be just value of type Route)
        -- TimerPage will be function of type Route that takes String (the result of our parse)
        [ UrlParser.format TimerPage (UrlParser.s "timer" </> UrlParser.s "timers" </> UrlParser.string)
          -- "#timer/timers/{id}"
        , UrlParser.format FormPage (UrlParser.s "timer")
          -- Just "#timer/"
        ]



-- (Location -> a)


hashParser : Navigation.Location -> Result String Route
hashParser location =
    location.hash
        |> String.dropLeft 1
        -- UrlParser.parse : formatter -> Parser formatter a -> String -> Result String a
        -- identity is a formatter that does nothing, and it's here because we can't omit it
        -- matchers is our function of type Parser formatter a
        -- String from location is the last parameter
        -- in the end the type variable "a" here will be the one of the value of our Route
        |>
            UrlParser.parse identity matchers



-- This is the first function called from the main module
-- The type of the parser is "Parser a"
-- (Result String Route) is a type returned from the parse function


parser : Navigation.Parser (Result String Route)
parser =
    -- makeParser : (Location -> a) -> Parser a
    -- So, hashParser is a function that will take location and return some type "a"
    -- Then makeParser will took this "a" and return "Parser a"
    Navigation.makeParser hashParser
