module Views.WorksheetOutput exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Views.Styling exposing (..)
import Views.QuestionOutput exposing (renderQuestionOutput)
import Models exposing (..)
import Messages exposing (..)

renderWorksheetOutput : Model -> Html Msg
renderWorksheetOutput model =
  div [ id "output" ]
    [ button [ onClick RenderPdf ] [ text "Render output to pdf" ]
    , h1 [ style panelHeading ] [ text model.title ]
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
