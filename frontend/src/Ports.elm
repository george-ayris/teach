port module Ports exposing (..)

import Models exposing (..)
import Messages exposing (..)
import Json.Encode as Json


port renderPdf : Json.Value -> Cmd msg


port imageUploaded : ImageUploadedInfo -> Cmd msg


port imageUploadedResult : (ImageUploadedResult -> msg) -> Sub msg


imageUploadedResultSubscription : Model -> Sub Msg
imageUploadedResultSubscription model =
    imageUploadedResult ImageUploadResultReceived
