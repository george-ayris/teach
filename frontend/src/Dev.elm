import TimeTravel.Html.App as TimeTravel
import Views exposing (view)
import Update exposing (update)
import Models exposing (Model)
import Messages exposing (Msg)

main =
  TimeTravel.program
    { init = init
    , view = view
    , update = update
    , subscriptions = \m -> Sub.none
    }

init : (Model, Cmd Msg)
init =
  (Model "My Worksheet" [], Cmd.none)
