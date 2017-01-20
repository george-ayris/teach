module Main exposing (..)

import Html.App as App
import Views exposing (view)
import Update exposing (update)
import Models exposing (Model)
import Messages exposing (Msg(..))
import Material
import Material.Layout as Layout
import Ports exposing (imageUploadedResultSubscription)


init : ( Model, Cmd Msg )
init =
    ( model, Layout.sub0 Mdl )


model : Model
model =
    Model "" [] Material.model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ imageUploadedResultSubscription model
        , Layout.subs Mdl model.mdl
        ]


main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
