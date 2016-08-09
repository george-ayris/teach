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
import Material
import Material.Dialog as Dialog
import Views.Resources as R

type alias Mdl =
  Material.Model

view : Model -> Html Msg
view model =
  div [ style mainContainer ]
    [ div [ style columnSpacer ] []
    , div [ style mainPanel ] [ renderWorksheetControls model ]
    , div [ style columnSpacer ] []
    , div [ style mainPanel ] [ renderWorksheetOutput model ]
    , div [ style columnSpacer ] []
    , dialog [1] model.mdl
    ]

dialog : QuestionId -> Mdl -> Html Msg
dialog questionId mdl =
  let
    elementId = "imageUpload" ++ (toString questionId)
  in
    Dialog.view []
        [ Dialog.content []
            [ input
              [ type' "file"
              , accept "image/*"
              , id elementId
              , on "change" (Json.succeed <| ImageUploaded { questionId = questionId, elementId = elementId })
              ] []
            , R.closeDialogButton questionId mdl
            ]
        ]
