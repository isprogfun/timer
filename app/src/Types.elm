module Types exposing (..)

import Time exposing (Time)
import Http
import DatePicker


-- MODEL


type alias Model =
    { route : Route
    , datePicker : DatePicker.DatePicker
    , currentTime : Time
    , form : Timer
    , timer : Maybe Timer
    }


type alias Timer =
    { name : String
    , date : Time
    , url : String
    }


type alias Flags =
    { now : Float
    }



-- MESSAGES


type
    Msg
    -- Form
    = SetName String
    | SetUrl String
    | SaveTimer
    | SaveTimerSuccess String
    | SaveTimerFail Http.Error
      -- Timer
    | Tick Time
    | GetTimerSuccess Timer
    | GetTimerFail Http.Error
      -- DatePicker
    | ToDatePicker DatePicker.Msg



-- ROUTING


type Route
    = FormPage
    | TimerPage String
    | NotFoundPage String
