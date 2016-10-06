module Form.Form exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.App
import String
import DatePicker


-- App

import Types exposing (..)


-- VIEW


view : Model -> Html Msg
view model =
    let
        submitDisabled =
            String.isEmpty model.form.name || model.form.date == 0
    in
        div [ class "add-wrapper" ]
            [ div [ class "title" ] [ text "Set data about your event" ]
            , div [ class "add" ]
                [ label
                    []
                    [ input
                        [ class "add-input"
                        , onInput SetName
                        , placeholder "Set a name"
                        ]
                        []
                    , text "*"
                    ]
                , label
                    []
                    [ input
                        [ class "add-input"
                        , onInput SetUrl
                        , placeholder "Set an Url"
                        ]
                        []
                    ]
                , label
                    []
                    [ DatePicker.view model.datePicker |> Html.App.map ToDatePicker, text "*" ]
                , button
                    [ class "add-button"
                    , type' "submit"
                    , onClick SaveTimer
                    , disabled submitDisabled
                    ]
                    [ text "Add new timer" ]
                ]
            ]
