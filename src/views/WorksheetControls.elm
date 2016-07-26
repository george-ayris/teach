module Views.WorksheetControls exposing (renderWorksheetControls)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Models exposing (..)
import Messages exposing (..)
import Views.Styling exposing (..)
import Views.QuestionControl exposing (renderControl)

renderWorksheetControls : Model -> Html Msg
renderWorksheetControls model =
  div []
    [ h1 [ style panelHeading
         , contenteditable True
         , on "blur" (Json.map FormTitleUpdated targetTextContent)
         , value model.title
         ] [ text model.title ]
    , div []
        [ div [] (List.indexedMap (renderControl <| List.length model.questions) model.questions)
        , button [ onClick QuestionAdded ] [ text "Add question" ]
        ]
    ]

targetTextContent : Json.Decoder String
targetTextContent =
  Json.at ["target", "textContent"] Json.string
