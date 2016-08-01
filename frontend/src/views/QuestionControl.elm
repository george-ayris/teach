module Views.QuestionControl exposing (renderControl)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (..)
import Messages exposing (..)
import Views.Styling exposing (..)
import Views.Resources as R
import Json.Decode as Json

renderControl : QuestionId -> Int -> Int -> Question -> Html Msg
renderControl parentIds listLength index ({ questionType, title, questionNumber, image } as question) =
  let
    questionId = parentIds ++ [ questionNumber ]
    isFirstElement = index == 0
    questionMovedUp = QuestionOrderChanged { oldQuestionId = questionId
                                          , questionIdToMoveAfter = parentIds ++ [ questionNumber - 2 ]
                                          }
    upButton = if isFirstElement
            then text ""
              else R.upButton questionMovedUp
    isLastElement = index == listLength - 1
    questionMovedDown = QuestionOrderChanged { oldQuestionId = questionId
                                             , questionIdToMoveAfter = parentIds ++ [ questionNumber + 1 ]
                                             }
    downButton = if isLastElement
                 then text ""
                 else R.downButton questionMovedDown
  in
    div []
      [ input
          [ type' "text"
          , placeholder R.questionPlaceholder
          , onInput (QuestionUpdated questionId << TitleUpdated)
          , value title ]
          [ text title ]
      , select [ onInput <| questionTypeChanged questionId ]
               (renderQuestionTypes questionId questionType)
      , upButton
      , downButton
      , R.removeButton <| QuestionRemoved questionId
      , addImageButton questionId image
      , renderQuestionSpecificControl questionId question
      ]

addImageButton : QuestionId -> Maybe Image -> Html Msg
addImageButton questionId image =
  -- Launch dialog here with input/drag and drop/paste area
  let
    elementId = "imageUpload" ++ (toString questionId)
  in
    case image of
      Just { name } ->
        div [] [ text <| "Current image: " ++ name ]

      Nothing ->
        div []
          [ input
            [ type' "file"
            , accept "image/*"
            , id elementId
            , on "change" (Json.succeed <| ImageUploaded { questionId = questionId, elementId = elementId })
            ]
            []
          ]

questionTypeChanged : QuestionId -> String -> Msg
questionTypeChanged id string =
  QuestionUpdated id <| TypeChanged (stringToQuestionType string)

renderQuestionTypes : QuestionId -> QuestionType -> List (Html Msg)
renderQuestionTypes id selectedOption =
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
    then List.map (renderQuestionType selectedOption) questionTypes
    else List.map (renderQuestionType selectedOption) <| questionTypes ++ [ SubQuestionContainer [] ]

renderQuestionType : QuestionType -> QuestionType -> Html Msg
renderQuestionType selectedOption questionType =
  let
    optionSelected =
      questionTypeToString selectedOption == questionTypeToString questionType
  in
    option [ value <| questionTypeToString questionType, selected optionSelected ] [ text <| prettyPrint questionType ]

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
        , [ div [ style endOfSubQuestion ] [ button [ onClick <| SubQuestionAdded id ] [ text "Add sub-question" ]]]
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
