module Views.WorksheetControls exposing (renderWorksheetControls)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Models exposing (..)
import Messages exposing (..)
import Views.Styling exposing (..)
import Views.QuestionControl exposing (renderControl)
import Material
import Material.Button as Button
import Material.List as MList

type alias Mdl =
  Material.Model

renderWorksheetControls : Model -> Html Msg
renderWorksheetControls model =
  let
    controls = List.indexedMap (renderControl [] model.mdl <| List.length model.questions) model.questions
  in
    div []
      [ h1 [ style panelHeading
           , contenteditable True
           , on "blur" (Json.map FormTitleUpdated targetTextContent)
           , value model.title
           ] [ text model.title ]
      , div []
          [ MList.ul [] <| List.concat
              [ (List.map (\x -> MList.li [] [ MList.content [] [x]]) controls)
              , [ MList.li [] <| [ MList.content []
                  [ Button.render Mdl [0] model.mdl
                      [ Button.raised
                      , Button.ripple
                      , Button.onClick QuestionAdded
                      , Button.colored
                      ]
                      [ text "Add question" ]
                  ]]
                ]
              ]
          ]
      ]

targetTextContent : Json.Decoder String
targetTextContent =
  Json.at ["target", "textContent"] Json.string
