import Html.App as App
import Views exposing (view)
import Update exposing (update)

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
