module Views.QuestionControl exposing (renderControl)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (..)
import Messages exposing (..)
import Views.Styling exposing (..)
import Views.Resources as R

renderControl : QuestionId -> Int -> Int -> Question -> Html Msg
renderControl parentIds listLength index ({ questionType, title, questionNumber } as question) =
  let
   isFirstElement = index == 0
   isLastElement = index == listLength - 1
   questionId = parentIds ++ [ questionNumber ]
   questionMovedUp = QuestionOrderChanged { oldQuestionId = questionId
                                          , questionIdToMoveAfter = parentIds ++ [ questionNumber - 2 ]
                                          }
   questionMovedDown = QuestionOrderChanged { oldQuestionId = questionId
                                            , questionIdToMoveAfter = parentIds ++ [ questionNumber + 1 ]
                                            }
  in
    div []
      [ input
          [ type' "text"
          , placeholder R.questionPlaceholder
          , onInput (QuestionUpdated questionId << TitleUpdated)
          , value title ]
          [ text title ]
      , select [ onInput <| questionTypeChanged questionId
               , value <| questionTypeToString questionType
               ] (renderQuestionTypes questionId)
      , if isFirstElement
        then text ""
        else R.upButton questionMovedUp
      , if isLastElement
        then text ""
        else R.downButton questionMovedDown
      , R.removeButton <| QuestionRemoved questionId
      , renderQuestionSpecificControl questionId question
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
    if List.length id > 2
    then List.map renderQuestionType questionTypes
    else List.map renderQuestionType <| questionTypes ++ [ SubQuestionContainer [] ]

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

renderQuestionSpecificControl : QuestionId -> Question -> Html Msg
renderQuestionSpecificControl id ({ questionType, title } as question) =
  case questionType of
    MultipleChoice { options } ->
      div [] <| List.concat
        [ List.map (renderOption id) options
        , [ div [] [ button [ onClick <| QuestionUpdated id MultipleChoiceOptionAdded ] [ text "Add option" ]]]
        ]

    SubQuestionContainer questions ->
      div [ style subQuestionContainer ] <| List.concat
        [ List.indexedMap (renderControl id <| List.length questions) questions
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
