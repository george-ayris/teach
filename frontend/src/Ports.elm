port module Ports exposing (..)

import Models exposing (Model)
import Json.Encode

port renderPdf : Json.Encode.Value -> Cmd msg
