module Types exposing (..)

import Time exposing (Time)
import Http
import DatePicker
import Navigation


-- MODEL


type alias Model =
    { route : Route
    , datePicker : DatePicker.DatePicker
    , currentTime : Time
    , form : Timer
    , timer : Maybe Timer
    , apiUrl : String
    }


type alias Timer =
    { name : String
    , date : Time
    , url : String
    }


type alias Flags =
    { now : Float
    , apiUrl : String
    }



-- MESSAGES


type
    Msg
    -- Form
    = SetName String
    | SetUrl String
    | SaveTimer
    | SaveTimerAnswer (Result Http.Error String)
      -- Timer
    | Tick Time
    | GetTimerAnswer (Result Http.Error Timer)
    | GoToForm
      -- DatePicker
    | ToDatePicker DatePicker.Msg
      -- Location
    | OnLocationChange Navigation.Location



-- ROUTING


type Route
    = FormPage
    | TimerPage String
    | NotFoundPage
