module Json exposing (encodeModel, encodeImageUploadedInfo)

import Json.Encode as Json
import Models exposing (..)

encodeModel : Model -> Json.Value
encodeModel { questions, title } =
  Json.object
    [ ("title", Json.string title) ]

encodeImageUploadedInfo : QuestionId -> String -> Json.Value
encodeImageUploadedInfo questionId elementId =
  let
    encodedQuestionId =
      questionId
      |> List.map (Json.int)
      |> Json.list
  in
    Json.object
      [ ("questionId", encodedQuestionId)
      , ("elementId", Json.string elementId)
      ]
