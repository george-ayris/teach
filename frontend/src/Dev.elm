import TimeTravel.Html.App as TimeTravel
import Views exposing (view)
import Update exposing (update)
import Models exposing (Model)
import Messages exposing (Msg)
import Material
import Ports exposing (imageUploadedResultSubscription)

main =
  TimeTravel.program
    { init = init
    , view = view
    , update = update
    , subscriptions = imageUploadedResultSubscription
    }

init : (Model, Cmd Msg)
init =
  (Model "My Worksheet" [] Material.model, Cmd.none)
