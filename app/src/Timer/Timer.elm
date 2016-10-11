module Timer.Timer exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Date


-- App

import Types exposing (..)


-- VIEW


view model id =
    case model.timer of
        Nothing ->
            div [] []

        Just timer ->
            let
                date =
                    Date.fromTime timer.date

                day =
                    Date.day date |> toString

                month =
                    Date.month date |> toString

                year =
                    Date.year date |> toString

                millisecondsLeft =
                    timer.date - model.currentTime

                yearsLeft =
                    -- TODO: consider leap years
                    millisecondsLeft / (1000 * 60 * 60 * 24 * 365) |> floor

                daysleft =
                    toFloat (round millisecondsLeft % (1000 * 60 * 60 * 24 * 365)) / (1000 * 60 * 60 * 24) |> floor

                hoursLeft =
                    toFloat (round millisecondsLeft % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60) |> floor

                minutesLeft =
                    toFloat (round millisecondsLeft % (1000 * 60 * 60)) / (1000 * 60) |> floor

                secondsLeft =
                    toFloat (round millisecondsLeft % (1000 * 60)) / (1000) |> floor
            in
                div []
                    [ div [ class "timer__new", onClick GoToForm ] [ text "Create new" ]
                    , div
                        [ class "timer" ]
                        [ p [ class "timer__name" ]
                            [ if timer.url /= "" then
                                a [ href timer.url, target "blank" ] [ text timer.name ]
                              else
                                text timer.name
                            ]
                        , p [ class "timer__date" ] [ text (day ++ " " ++ month ++ " " ++ year) ]
                        , p [ class "timer__left" ]
                            (if model.currentTime > timer.date then
                                [ text "Event is over!" ]
                             else if model.currentTime /= 0 then
                                [ (if yearsLeft /= 0 then
                                    toString yearsLeft ++ " years "
                                   else
                                    ""
                                  )
                                    ++ toString daysleft
                                    ++ " days "
                                    ++ toString hoursLeft
                                    ++ " hours "
                                    ++ toString minutesLeft
                                    ++ " minutes "
                                    ++ toString secondsLeft
                                    ++ " seconds "
                                    ++ " left before event"
                                    |> text
                                ]
                             else
                                []
                            )
                        ]
                    ]
