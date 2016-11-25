module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Task
import Json.Decode
import Json.Encode
import Navigation
import Time exposing (Time)
import Date exposing (Date, Day(..), day, dayOfWeek, month, year)
import DatePicker exposing (defaultSettings)
import Debug


-- App

import Routing
import Timer.Timer
import Form.Form
import Types exposing (..)


-- MAIN


main : Program Flags Model Msg
main =
    -- The location goes through the parser function from Routing
    -- Result of the parser function will return some "data" that will be fed to init function
    Navigation.programWithFlags OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- INIT


init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags location =
    let
        route =
            Routing.parseLocation location

        isDisabled date =
            Date.toTime date < flags.now

        ( datePicker, datePickerFx ) =
            DatePicker.init
                -- Changing some settings
                { defaultSettings
                    | firstDayOfWeek = Mon
                    , isDisabled = isDisabled
                    , placeholder = "Choose a date"
                }
    in
        { route = route
        , datePicker = datePicker
        , currentTime = 0
        , form =
            { name = ""
            , date = 0
            , url = ""
            }
        , timer = Nothing
        , apiUrl = flags.apiUrl
        }
            ! [ Cmd.map ToDatePicker datePickerFx, initialCommand flags.apiUrl route ]


initialCommand : String -> Route -> Cmd Msg
initialCommand apiUrl route =
    case route of
        FormPage ->
            Cmd.none

        NotFoundPage ->
            Cmd.none

        TimerPage id ->
            getTimer apiUrl id



-- VIEW


view : Model -> Html Msg
view model =
    case model.route of
        FormPage ->
            Form.Form.view model

        TimerPage id ->
            Timer.Timer.view model id

        NotFoundPage ->
            div [] [ text "404" ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every Time.second Tick



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- Form
        SetName name ->
            let
                form =
                    model.form
            in
                ( { model | form = { form | name = name } }, Cmd.none )

        SetUrl url ->
            let
                form =
                    model.form
            in
                ( { model | form = { form | url = url } }, Cmd.none )

        SaveTimer ->
            ( model, saveTimer model )

        SaveTimerAnswer (Ok id) ->
            ( model, Navigation.newUrl ("#timers/" ++ id) )

        SaveTimerAnswer (Err _) ->
            ( model, Cmd.none )

        -- Timer
        Tick time ->
            ( { model | currentTime = time }, Cmd.none )

        GetTimerAnswer (Ok timer) ->
            ( { model | timer = Just timer }, Cmd.none )

        GetTimerAnswer (Err _) ->
            ( { model | route = NotFoundPage }, Cmd.none )

        GoToForm ->
            ( model, Navigation.newUrl ("#") )

        -- DatePicker
        ToDatePicker msg ->
            let
                ( datePicker, datePickerFx, mDate ) =
                    DatePicker.update msg model.datePicker

                form =
                    model.form

                date =
                    case mDate of
                        Nothing ->
                            form.date

                        Just date ->
                            Date.toTime date
            in
                { model
                    | datePicker = datePicker
                    , form = { form | date = date }
                }
                    ! [ Cmd.map ToDatePicker datePickerFx ]

        -- Location
        OnLocationChange location ->
            let
                route =
                    Routing.parseLocation location

                isDisabled date =
                    Date.toTime date < model.currentTime

                ( datePicker, datePickerFx ) =
                    DatePicker.init
                        -- Changing some settings
                        { defaultSettings
                            | firstDayOfWeek = Mon
                            , isDisabled = isDisabled
                            , placeholder = "Choose a date"
                        }
            in
                { model | route = route, datePicker = datePicker }
                    ! [ Cmd.map ToDatePicker datePickerFx, initialCommand model.apiUrl route ]



-- Form functions


saveTimer : Model -> Cmd Msg
saveTimer model =
    let
        url =
            model.apiUrl ++ "/timers/create"

        form =
            model.form

        body =
            Json.Encode.object
                [ ( "name", Json.Encode.string form.name )
                , ( "date", Json.Encode.float form.date )
                , ( "url", Json.Encode.string form.url )
                ]
                |> Json.Encode.encode 0
                |> Http.stringBody "text/plain"
    in
        Http.send SaveTimerAnswer <| Http.post url body decodeJson


decodeJson : Json.Decode.Decoder String
decodeJson =
    Json.Decode.at [ "id" ] Json.Decode.string



-- Timer functions


getTimer : String -> String -> Cmd Msg
getTimer apiUrl id =
    let
        url =
            apiUrl ++ "/timers/" ++ id
    in
        Http.send GetTimerAnswer <| Http.get url decodeTimerJson


decodeTimerJson : Json.Decode.Decoder Timer
decodeTimerJson =
    Json.Decode.map3 Timer
        (Json.Decode.at [ "name" ] Json.Decode.string)
        (Json.Decode.at [ "date" ] Json.Decode.float)
        (Json.Decode.at [ "url" ] Json.Decode.string)
