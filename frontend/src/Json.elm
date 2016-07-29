module Json exposing (jsonEncodeModel)

import Json.Encode as JE
import Models exposing (..)

jsonEncodeModel : Model -> JE.Value
jsonEncodeModel { questions, title } =
  JE.object
    [ ("title", JE.string title) ]
