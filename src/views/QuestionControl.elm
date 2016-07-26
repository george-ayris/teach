module Views.QuestionControl exposing (renderControl)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (..)
import Messages exposing (..)
import Views.Styling exposing (..)
import Views.Resources as R

renderControl : Int -> Int -> Question -> Html Msg
renderControl listLength index ({ id, questionType, title, questionNumber } as question) =
  let
   isFirstElement = index == 0
   isLastElement = index == listLength - 1
   questionMovedUp = QuestionOrderChanged { oldQuestionNumber = questionNumber, newQuestionNumber = questionNumber - 1, id = id }
   questionMovedDown = QuestionOrderChanged { oldQuestionNumber = questionNumber, newQuestionNumber = questionNumber + 1, id = id }
  in
    div []
      [ input
          [ type' "text"
          , placeholder R.questionPlaceholder
          , onInput (QuestionUpdated id << TitleUpdated)
          , value title ]
          [ text title ]
      , select [ onInput <| questionTypeChanged id, value <| questionTypeToString questionType ] (renderQuestionTypes id)
      , if isFirstElement
        then text ""
        else R.upButton questionMovedUp
      , if isLastElement
        then text ""
        else R.downButton questionMovedDown
      , R.removeButton <| QuestionRemoved id
      , renderQuestionSpecificControl question
      ]

questionTypeChanged : QuestionId -> String -> Msg
questionTypeChanged id string =
  QuestionUpdated id <| TypeChanged (stringToQuestionType string)

renderQuestionTypes : QuestionId -> List (Html Msg)
renderQuestionTypes id =
  let
    questionTypes =
      [ ShortAnswer
      , MediumAnswer
      , LongAnswer
      , TrueFalse
      , MultipleChoice { options = [], uid = 0 }
      ]
  in
    case id of
      ParentId _ (ParentId _ (Id _)) ->
        List.map renderQuestionType questionTypes
      _ ->
        List.map renderQuestionType <| questionTypes ++ [ SubQuestionContainer [] ]

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
    SubQuestionContainer _ -> "Or add a sub-question"

renderQuestionSpecificControl : Question -> Html Msg
renderQuestionSpecificControl ({ id, questionType, title } as question) =
  case questionType of
    MultipleChoice { options } ->
      div [] <| List.concat
        [ List.map (renderOption id) options
        , [ div [] [ button [ onClick <| QuestionUpdated id MultipleChoiceOptionAdded ] [ text "Add option" ]]]
        ]

    SubQuestionContainer questions ->
      div [ style subQuestionContainer ] <| List.concat
        [ List.indexedMap (renderControl <| List.length questions) questions
        , [ button [ onClick <| SubQuestionAdded id ] [ text "Add sub-question" ] ]
        ]

    _ -> text ""

renderOption : QuestionId -> Option -> Html Msg
renderOption questionId option =
  div []
    [ input
        [ type' "text"
        , placeholder R.optionPlaceholder
        , onInput (QuestionUpdated questionId << MultipleChoiceOptionUpdated option.id)
        , value option.value
        ] [ text option.value ]
    , R.removeButton <| QuestionUpdated questionId <| MultipleChoiceOptionRemoved option.id
    ]
