import Html.App as App
import Views exposing (view)
import Update exposing (update)
import Models exposing (Model)
import Messages exposing (Msg)
import Ports exposing (imageUploadedResultSubscription)

main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = imageUploadedResultSubscription
    }

init : (Model, Cmd Msg)
init =
  (Model "My Worksheet" [] Nothing, Cmd.none)
