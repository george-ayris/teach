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
import Material.Textfield as Textfield
import Material.Typography as Typo
import Material.Options as Options exposing (css)
import Views.Resources as R

type alias Mdl =
  Material.Model

renderWorksheetControls : Model -> Html Msg
renderWorksheetControls model =
  let
    controls = List.indexedMap (renderControl [] model.mdl <| List.length model.questions) model.questions
  in
    div []
      [ Options.div
          [ Typo.center
          , css "padding" "24px 24px 0 24px"
          ]
          [ Textfield.render Mdl [0] model.mdl
              [ Textfield.onInput FormTitleUpdated
              , Textfield.value model.title
              , Textfield.label R.titlePlaceholder
              , css "width" "100%"
              ]
          ]
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
