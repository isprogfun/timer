module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Task
import Debug
import Json.Decode exposing ((:=))
import Json.Encode
import Navigation
import Time exposing (Time)
import Date exposing (Date, Day(..), day, dayOfWeek, month, year)
import DatePicker exposing (defaultSettings)


-- App imports

import Routing
import Timer.Timer
import Form.Form
import Types exposing (..)


-- MAIN


main : Program Flags
main =
    -- The location goes through the parser function from Routing
    -- Result of the parser function will return some "data" that will be fed to init function
    Navigation.programWithFlags Routing.parser
        { init = init
        , urlUpdate = urlUpdate
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- INIT


init : Flags -> Result String Route -> ( Model, Cmd Msg )
init flags result =
    let
        route =
            Routing.routeFromResult result

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
        }
            ! [ Cmd.map ToDatePicker datePickerFx, initialCommand route ]


urlUpdate : Result String Route -> Model -> ( Model, Cmd Msg )
urlUpdate result model =
    let
        route =
            Routing.routeFromResult result

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
            ! [ Cmd.map ToDatePicker datePickerFx, initialCommand route ]


initialCommand : Route -> Cmd Msg
initialCommand route =
    case route of
        FormPage ->
            Cmd.none

        NotFoundPage message ->
            Cmd.none

        TimerPage id ->
            getTimer id



-- VIEW


view : Model -> Html Msg
view model =
    case model.route of
        FormPage ->
            Form.Form.view model

        TimerPage id ->
            Timer.Timer.view model id

        NotFoundPage message ->
            div [] [ text "Page not found" ]



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

        SaveTimerSuccess id ->
            ( model, Navigation.newUrl ("/timer/timers/" ++ id) )

        SaveTimerFail error ->
            ( model, Cmd.none )

        -- Timer
        Tick time ->
            ( { model | currentTime = time }, Cmd.none )

        GetTimerSuccess timer ->
            ( { model | timer = Just timer }, Cmd.none )

        GetTimerFail error ->
            ( { model | route = NotFoundPage "Timer not found" }, Cmd.none )

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



-- Form


saveTimer : Model -> Cmd Msg
saveTimer ({ form } as model) =
    let
        url =
            "https://isprogfun.ru/api/timer/timers/create"

        body =
            Json.Encode.encode 0
                (Json.Encode.object
                    [ ( "name", Json.Encode.string form.name )
                    , ( "date", Json.Encode.float form.date )
                    , ( "url", Json.Encode.string form.url )
                    ]
                )
                |> Http.string
    in
        Task.perform SaveTimerFail SaveTimerSuccess (Http.post decodeJson url body)


decodeJson : Json.Decode.Decoder String
decodeJson =
    Json.Decode.at [ "id" ] Json.Decode.string



-- Timer


getTimer : String -> Cmd Msg
getTimer id =
    let
        url =
            "https://isprogfun.ru/api/timer/timers/" ++ id
    in
        Task.perform GetTimerFail GetTimerSuccess (Http.get decodeTimerJson url)


decodeTimerJson : Json.Decode.Decoder Timer
decodeTimerJson =
    Json.Decode.object3 Timer
        ("name" := Json.Decode.string)
        ("date" := Json.Decode.float)
        ("url" := Json.Decode.string)
