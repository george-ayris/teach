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
import Material.Elevation as Elevation
import Material.Button as Button
import Material.Dialog as Dialog
import Material.Layout as Layout
import Material.Options as Options
import Views.Resources as R

type alias Mdl =
  Material.Model

view : Model -> Html Msg
view model =
  Layout.render Mdl model.mdl
    [ Layout.fixedHeader ]
    { header =
        [ Layout.row []
            [ Layout.title [] [ text "Teach" ]
            , Layout.spacer
            , Layout.navigation []
                [ Button.render Mdl [0] model.mdl
                    [ Button.ripple
                    , Button.onClick RenderPdf
                    ]
                    [ text "Create PDF" ]
                ]
            ]
        ]
    , drawer = []
    , tabs = ([], [])
    , main =
      [ div [ style mainContainer ]
          [ Options.div
              [ Options.attribute <| style mainPanel
              , Elevation.e2
              ] [ renderWorksheetControls model ]
          , Options.div
              [ Options.attribute <| style mainPanel
              , Elevation.e2
              ] [ renderWorksheetOutput model ]
          , dialog [1] model.mdl
          ]
      ]
    }

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
