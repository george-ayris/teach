module Views exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Models exposing (..)
import Messages exposing (..)
import Views.Styling exposing (..)
import Views.WorksheetOutput exposing (renderWorksheetOutput)
import Views.WorksheetControls exposing (renderWorksheetControls)
import Dialog

view : Model -> Html Msg
view model =
  div [ style mainContainer ]
    [ div [ style columnSpacer ] []
    , div [ style mainPanel ] [ renderWorksheetControls model ]
    , div [ style columnSpacer ] []
    , div [ style mainPanel ] [ renderWorksheetOutput model ]
    , div [ style columnSpacer ] []
    , Dialog.view <| Maybe.map imageUpload model.dialogInfo
    ]

imageUpload : QuestionId -> Dialog.Config Msg
imageUpload questionId =
  let
    elementId = "imageUpload" ++ (toString questionId)
    body = div []
            [ input
              [ type' "file"
              , accept "image/*"
              , id elementId
              , on "change" (Json.succeed <| ImageUploaded { questionId = questionId, elementId = elementId })
              ]
              []
            ]
  in
    { closeMessage = Just CloseImageUploadDialog
    , header = Nothing
    , body = Just body
    , footer = Nothing
    }
