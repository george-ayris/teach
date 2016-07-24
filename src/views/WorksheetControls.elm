module Views.WorksheetControls exposing (renderWorksheetControls)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Models exposing (..)
import Messages exposing (..)
import Views.Styling exposing (..)
import Views.Resources as R
import Views.QuestionSpecificControl exposing (renderQuestionSpecificControl)

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

renderControl : Int -> Int -> Question -> Html Msg
renderControl listLength index ({ id, questionType, title, questionNumber } as question) =
  let
   isFirstElement = index == 0
   isLastElement = index == listLength - 1
  in
    div []
      [ input
          [ type' "text", placeholder R.questionPlaceholder
          , onInput (QuestionUpdated id << TitleUpdated)
          , value title ]
          [ text title ]
      , select [ onInput <| questionTypeChanged id, value <| questionTypeToString questionType ] renderQuestionTypes
      , if isFirstElement
        then text ""
        else R.upButton <| QuestionOrderChanged { oldQuestionNumber = questionNumber, newQuestionNumber = questionNumber - 1 }
      , if isLastElement
        then text ""
        else R.downButton <| QuestionOrderChanged { oldQuestionNumber = questionNumber, newQuestionNumber = questionNumber + 1 }
      , R.removeButton <| QuestionRemoved id
      , renderQuestionSpecificControl question
      ]

questionTypeChanged : Int -> String -> Msg
questionTypeChanged id string =
  QuestionUpdated id <| TypeChanged (stringToQuestionType string)

renderQuestionTypes : List (Html Msg)
renderQuestionTypes =
  [ ShortAnswer
  , MediumAnswer
  , LongAnswer
  , TrueFalse
  , MultipleChoice { options = [], uid = 0 } ]
  |> List.map renderQuestionType

renderQuestionType : QuestionType -> Html Msg
renderQuestionType questionType =
  option [ value <| questionTypeToString questionType ] [ text <| prettyPrint questionType ]

prettyPrint : QuestionType -> String
prettyPrint questionType =
  case questionType of
    ShortAnswer -> "Short answer"
    MediumAnswer -> "Medium answer"
    LongAnswer -> "Long answer"
    TrueFalse -> "True/false"
    MultipleChoice _ -> "Multiple choice"
