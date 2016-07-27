import Html.App as App
import Views exposing (view)
import Update exposing (update)
import Models exposing (Model)
import Messages exposing (Msg)

main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = \m -> Sub.none
    }

init : (Model, Cmd Msg)
init =
  (Model "My Worksheet" [], Cmd.none)
