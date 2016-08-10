module Views.WorksheetOutput exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Views.Styling exposing (..)
import Views.QuestionOutput exposing (renderQuestionOutput)
import Models exposing (..)
import Messages exposing (..)
import Views.Resources as R

renderWorksheetOutput : Model -> Html Msg
renderWorksheetOutput model =
  div [ id "output" ]
    [ h1 [ style panelHeading ] [ text <| if model.title == "" then R.titlePlaceholder else model.title ]
    , div [] (List.indexedMap (renderOutput <| List.length model.questions) model.questions)
    ]

renderOutput : Int -> Int -> Question -> Html Msg
renderOutput listLength currentIndex question =
  if (listLength - 1) == currentIndex
  then renderOutputWith (text "") question
  else renderOutputWith (hr [] []) question

renderOutputWith : Html Msg -> Question -> Html Msg
renderOutputWith htmlElem question =
  div []
    [ renderQuestionOutput [] question
    , htmlElem
    ]
